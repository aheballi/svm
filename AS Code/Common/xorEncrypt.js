function encrypt(str, pwd) {
    var result="";
	for(i=0;i<str.length;++i)
	{
		result+=String.fromCharCode(pwd^str.charCodeAt(i));
	}
	return result;
}