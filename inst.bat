call .\apktool.bat b .\com.google.android.inputmethod.pinyin\ -o output.apk
call java -jar .\sign.jar .\output.apk
call adb install output.s.apk
 
