<?php

namespace App\Http\Controllers\V1\User;

use App\Exceptions\ApiException;
use App\Http\Controllers\Controller;
use App\Http\Resources\KnowledgeResource;
use App\Models\Knowledge;
use App\Models\User;
use App\Services\Plugin\HookManager;
use App\Services\UserService;
use App\Utils\Helper;
use Illuminate\Http\Request;

class KnowledgeController extends Controller
{
    private UserService $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    public function fetch(Request $request)
    {
        $request->validate([
            'id' => 'nullable|sometimes|integer|min:1',
            'language' => 'nullable|sometimes|string|max:10',
            'keyword' => 'nullable|sometimes|string|max:255',
        ]);

        return $request->input('id')
            ? $this->fetchSingle($request)
            : $this->fetchList($request);
    }

    private function fetchSingle(Request $request)
    {
        $knowledge = $this->buildKnowledgeQuery()
            ->where('id', $request->input('id'))
            ->first();

        if (!$knowledge) {
            return $this->fail([500, __('Article does not exist')]);
        }

        $knowledge = $knowledge->toArray();
        $knowledge = $this->processKnowledgeContent($knowledge, $request->user());

        return $this->success(KnowledgeResource::make($knowledge));
    }

    private function fetchList(Request $request)
    {
        $builder = $this->buildKnowledgeQuery(['id', 'category', 'title', 'updated_at', 'body'])
            ->where('language', $request->input('language'))
            ->orderBy('sort', 'ASC');

        $keyword = $request->input('keyword');
        if ($keyword) {
            $builder = $builder->where(function ($query) use ($keyword) {
                $query->where('title', 'LIKE', "%{$keyword}%")
                    ->orWhere('body', 'LIKE', "%{$keyword}%");
            });
        }

        $knowledges = $builder->get()
            ->map(function ($knowledge) use ($request) {
                $knowledge = $knowledge->toArray();
                $knowledge = $this->processKnowledgeContent($knowledge, $request->user());
                return KnowledgeResource::make($knowledge);
            })
            ->groupBy('category');

        return $this->success($knowledges);
    }

    private function buildKnowledgeQuery(array $select = ['*'])
    {
        return Knowledge::select($select)->where('show', 1);
    }

    private function processKnowledgeContent(array $knowledge, User $user): array
    {
        if (!isset($knowledge['body'])) {
            return $knowledge;
        }

        if (!$this->userService->isAvailable($user)) {
            $this->formatAccessData($knowledge['body']);
        }
        $subscribeUrl = Helper::getSubscribeUrl($user['token']);
        $knowledge['body'] = $this->replacePlaceholders($knowledge['body'], $subscribeUrl);

        // 替换 Apple ID 占位符
        $this->apple($knowledge['body']); // 注意引用传递

        return $knowledge;
    }


    private function apple(&$body)
    {
        $maxAccounts = 10; // 最大支持10个账号

        try {
            // 使用 file_get_contents 获取 JSON
            $opts = [
                "http" => [
                    "method" => "GET",
                    "timeout" => 5, // 5秒超时
                ]
            ];
            $context = stream_context_create($opts);
            $response = file_get_contents("https://app.derk.top/shareapi/YmVzdHZwbjcK", false, $context);

            if (!$response) {
                throw new \Exception("无法获取 API 数据");
            }

            $data = json_decode($response, true);

            if (!isset($data['accounts']) || !is_array($data['accounts'])) {
                throw new \Exception("API 返回格式不正确");
            }

            $accounts = $data['accounts'];

            for ($i = 0; $i < $maxAccounts; $i++) {
                $account = $accounts[$i] ?? [];
                $body = str_replace("{{apple_id$i}}", $account['username'] ?? '获取失败', $body);
                $body = str_replace("{{apple_pw$i}}", $account['password'] ?? '获取失败', $body);
                $body = str_replace("{{apple_status$i}}", isset($account['status']) ? ($account['status'] ? "✅" : "❎") : '获取失败', $body);
                $body = str_replace("{{apple_time$i}}", $account['last_check'] ?? '获取失败', $body);
            }

        } catch (\Exception $e) {
            for ($i = 0; $i < $maxAccounts; $i++) {
                $body = str_replace("{{apple_id$i}}", '获取失败', $body);
                $body = str_replace("{{apple_pw$i}}", '获取失败', $body);
                $body = str_replace("{{apple_status$i}}", '获取失败', $body);
                $body = str_replace("{{apple_time$i}}", '获取失败', $body);
            }
        }
    }

    private function formatAccessData(&$body): void
    {
        $rules = [
            [
                'type' => 'regex',
                'pattern' => '/<!--access start-->(.*?)<!--access end-->/s',
                'replacement' => '<div class="v2board-no-access">' . __('You must have a valid subscription to view content in this area') . '</div>'
            ]
        ];

        $this->applyReplacementRules($body, $rules);
    }


    private function replacePlaceholders(string $body, string $subscribeUrl): string
    {
        $rules = [
            [
                'type' => 'string',
                'search' => '{{siteName}}',
                'replacement' => admin_setting('app_name', 'XBoard')
            ],
            [
                'type' => 'string',
                'search' => '{{subscribeUrl}}',
                'replacement' => $subscribeUrl
            ],
            [
                'type' => 'string',
                'search' => '{{urlEncodeSubscribeUrl}}',
                'replacement' => urlencode($subscribeUrl)
            ],
            [
                'type' => 'string',
                'search' => '{{safeBase64SubscribeUrl}}',
                'replacement' => str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($subscribeUrl))
            ]
        ];

        $this->applyReplacementRules($body, $rules);
        return $body;
    }

    private function applyReplacementRules(string &$body, array $rules): void
    {
        foreach ($rules as $rule) {
            if ($rule['type'] === 'regex') {
                $body = preg_replace($rule['pattern'], $rule['replacement'], $body);
            } else {
                $body = str_replace($rule['search'], $rule['replacement'], $body);
            }
        }
    }
}
