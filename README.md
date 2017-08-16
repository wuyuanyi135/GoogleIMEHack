# GoogleIMEHack
### Always correct by hacking the .apk. No root. No Xposed Framework.
***Gboard not tested.***
# Intro
I bought a Samsung Galaxy S8 and started to use [Google Pinyin Input](https://play.google.com/store/apps/details?id=com.google.android.inputmethod.pinyin&hl=en). Everything was fine until I found that the suggestion bar did not come up when inputting in some search bar especially in Google's product (Chrome!!!). It was a nightmare for "swypers" because you don't have candidates to correct. 

I thought it was a bug until John Bowdre [said](https://productforums.google.com/forum/#!topic/nexus/N-To9B037BM):

>Hi Roadguide,
> 
>As Nikhil alluded, some applications [deliberately suppress](https://developer.android.com/reference/android/text/InputType.html#TYPE_TEXT_FLAG_NO_SUGGESTIONS) the keyboard's ability to suggest words. This is often true for web browser address bars (which are generally intended to accept URLs rather than words) or password input fields (you don't want to suggest passwords, as that would kind of defeat the purpose). 
> 	
>It's up to each application's developer to decide whether or not they want to enable this flag for input fields in their apps - all that the Google Keyboard does is honor the developers' requests.
> 	
>In the case of Twitter and Facebook, you may want to contact those developers to see if they might consider changing their apps to support word predictions.
> 	
>Cheers,
>John

As suggested by some guys, the only working solution was to use Xposed module [Always Correct](http://repo.xposed.info/module/com.elesbb.xposedinputautocorrectalways) by elesbb. I still like the warranty, so I do not root my phone. Xposed Framework looks not compatible with Nougat as well. So I decided to find some other ways to "always correct" my swipes.

# Prerequisite

* Phone with Developer Options enabled (not necessary, just for adb installation).
* APK extraction tool. I used [App Extractor](https://play.google.com/store/apps/details?id=com.ext.ui&hl=en&rdid=com.ext.ui).
* [APKTool](https://ibotpeaches.github.io/Apktool/)
* APK sign tool. I used [appium/sign](https://github.com/appium/sign).

No files provided in this repository. You can download them from the links.


# Steps

## Get the APK
Use your APK extraction tool, download and send the apk to your computer

## Uninstall the original IME

## Disassembly
Put the apk in the same directory as APKTool. Run `.\apktool.bat d  \com.google.android.inputmethod.pinyin.apk` to get the disassembled .smali codes.
change directory into the folder called "smali" in the generated folder.

## Modify .smali file

### Hackable entries
There are essentially lots of injection points to override the behavior. For example

File: `ns.smali` (This file locates in the `smali` folder)
Class: `Lns`
Function: `u`
Description:  computes if `TYPE_TEXT_FLAG_NO_SUGGESTIONS` flag (0x80000) is set. 

File: `com\google\android\apps\inputmethod\libs\latin\LatinIme.smali`
Class: `Lcom/google/android/apps/inputmethod/libs/latin/LatinIme` 
Function: `computeShouldShowSuggestions`
Description:  English keyboard implementation that computes whether the suggestion bar should be shown or not.

File: `com\google\android\apps\inputmethod\libs\framework\ime\AbstractIme.smali`
Class: `Lcom/google/android/apps/inputmethod/libs/framework/ime/AbstractIme` 
Function: `computeShouldShowSuggestions`
Description:  Super class of the previous one. Hacking this will affect all keyboards.


----------

### Steps to hack
I chose to hack `LatinIme.smali` because the English keyboard is problematic while Chinese keyboard looks good. Hacking the base class or the detection logic function if you need to.

 1. Open the smali file using any text editor
 2. Search for `computeShouldShowSuggestions`
 3. You will find this line`.method public computeShouldShowSuggestions(Landroid/view/inputmethod/EditorInfo;)Z`
 4. Follow the indentation and get to the end `return v0`. Put a line `const/4 v0, 0x1` before `return v0` but after `:cond_0`. It's basically a dirty hack forcing return True.

### After change
```smali
.method public computeShouldShowSuggestions(Landroid/view/inputmethod/EditorInfo;)Z
    .locals 3

    .prologue
    const/4 v0, 0x0

    .line 503
    iget-object v1, p0, Lcom/google/android/apps/inputmethod/libs/latin/LatinIme;->mPreferences:Lrk;

    .line 20330
    const v2, 0x7f1001fd

    invoke-virtual {v1, v2, v0}, Lrk;->a(IZ)Z

    move-result v1

    .line 503
    if-eqz v1, :cond_0

    .line 504
    invoke-super {p0, p1}, Lcom/google/android/apps/inputmethod/libs/framework/ime/AbstractIme;->computeShouldShowSuggestions(Landroid/view/inputmethod/EditorInfo;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v0, 0x1

    :cond_0
    const/4 v0, 0x1      # <----- Add this line
    return v0
.end method
```

## Pack, sign, install
Run this command: `.\apktool.bat b .\com.google.android.inputmethod.pinyin\ -o output.apk`
Sign: `java -jar .\sign.jar .\output.apk`
Install: `adb install output.s.apk`

You can also use the batch script `inst.bat` in this repository. Note that the name may be different.
If there is error like `Failure [INSTALL_FAILED_ALREADY_EXISTS: Attempt to re-install com.google.android.inputmethod.pinyin without first uninstalling.]`, just do what suggested. The `uninst.bat` can help you to do that.
If you do not like adb, copy the signed apk to your phone to install.
 
# Ending
![Enjoy](https://raw.github.com/wuyuanyi135/GoogleIMEHack/master/enjoy.png)
