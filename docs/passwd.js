var password=document.getElementById("password");

function genPassword() {
    var chars = "23456789abcdefghkmnpqrstwxyzABCDEFGHKMNOPQRSTWXYZ$#@";
    var passwordLength = 18;
    var password = "";
    for (var i = 1; i <= passwordLength; i++) {
        var randomNumber = Math.floor(Math.random() * chars.length);
        password += chars.substring(randomNumber, randomNumber +1);
    }
    document.getElementById("password").value = password;
}

function copyPassword() {
    var copyText = document.getElementById("password");
    copyText.select();
    copyText.setSelectionRange(0, 999);
    document.execCommand("copy");
}