#!/bin/fish
set decdir /home/$USER/.local/share/aurorae/themes/Ultimate-Cus/decoration.svg
set rcdir /home/$USER/.local/share/aurorae/themes/Ultimate-Cus/Ultimate-Cusrc
set selection (sed '1q;d' /home/$USER/.local/share/aurorae/themes/Ultimate-Cus/curfile)
set c1 (sed '272q;d' $decdir)
set color (string sub $c1 -l (expr (string length $c1) - 1))
set o1 (sed '270q;d' $decdir)
set opac (string sub $o1 -l (expr (string length $o1) - 1))
set b1 (sed '24q;d' $rcdir)
set bsize (string sub $b1 --start 14)
set ct (sed '2q;d' /home/$USER/.local/share/konsole/Ultimate-Cus.colorscheme)
set colort (string sub $ct -s 7)
while not test $status -eq 10
and test -z $val
    set stati (yad --form --columns=2 --field=Change\ Opacity:FBTN "fish -c \"echo 3 && killall yad\"" --field=Change\ Color:FBTN "fish -c \"echo 2 && killall yad\"" --field=Set\ Button\ Size:FBTN "fish -c \"echo 4 && killall yad\"" --field=Set\ Button\ Theme:FBTN "fish -c \"echo 5 && killall yad\"" --field=Save\ Profile:FBTN "fish -c \"echo 6 && killall yad\"" --field=Load\ Profile:FBTN "fish -c \"echo 7 && killall yad\"" --button=Apply\ Changes:"fish -c \"echo 11 && killall yad\"" --button=Exit:"fish -c \"echo 10 && killall yad\"" --center)
    if test $status -eq 252
        exit
    end
    #Switch statement
    switch $stati
    #Color selection
    case 2
        set valcolor (yad --color --center --gtk-palette --init-color=$color --button="Quit Script":10 --button=Cancel:45 --button=Select:0 --title=Color\ Selection --mode=rgb)
        set ct1 (string sub $valcolor -s 4)
        if test $status -eq 10
            exit
        end
        if not test -z $ct1
            set colort (python -c "print('#%02x%02x%02x' % $ct1)")
        end
        if not test -z $valcolor
            set color $valcolor
        end
    #Opcaity selection
    case 3
        set opval (string sub (python -c "print($opac*100)") -l 2)
        set valopac (yad --scale --text='Set Opacity' --value=$opval --width=320 --height=160 --center --button="Quit Script":10 --button=Cancel:45 --button=Select:0)
        if test $status -eq 10
            exit
        end
        if not test -z $valopac
            set opac (lua -e "print($valopac/100)")
        end
    #Button size selection
    case 4
        set valbsize (yad --scale --text='Set Button Size' --value=$bsize --min-value=12 --max-value=50 --width=320 --height=160 --center --button="Quit Script":10 --button=Cancel:45 --button=Select:0)
        if test $status -eq 10
            exit
        end
        if not test -z $valbsize
            set bsize $valbsize
        end
    #Button theme selection
    case 5
        set sel1 (yad --list --column=Themes BT1 BT2 BT3 BT4 BT5 BT6 --text="Current\ Theme: $selection" --text-align=left --width=220 --height=230 --center --button="Quit Script":10 --button=Cancel:45 --button=Select:0)
        if test $status -eq 10
            exit
        end
        if not test -z $sel1
            set -g selection (string sub $sel1 -l 3)
        end
    #Save profile
    case 6
        set sfile (yad --file --save --center)
        echo Opacity:\n$opac\nColor:\n$color\nButton Theme:\n$selection\nButton Size:\n$bsize | cat > "$sfile.actp"
    #Load profile
    case 7
        set lfile (yad --file --center)
        set -g opac (sed '2q;d' $lfile)
        set -g color (sed '4q;d' $lfile)
        set -g selection (sed '6q;d' $lfile)
        set -g bsize (sed '8q;d' $lfile)
    #Quit script
    case 10
        exit
    #Apply Changes
    case 11
        set -g val 1
        sed -i "270s/.*/$opac;/" $decdir
        sed -i "272s/.*/$color;/" $decdir
        sed -i "94s/.*/Opacity=$opac/" /home/$USER/.local/share/konsole/Ultimate-Cus.colorscheme
        sed -i "2s/.*/Color=$colort/" /home/$USER/.local/share/konsole/Ultimate-Cus.colorscheme
        if not test -z $selection
            cp /home/$USER/.local/share/aurorae/themes/Ultimate-Cus/Files/Styles/$selection/* /home/$USER/.local/share/aurorae/themes/Ultimate-Cus/
            if test $selection = "BT6"
                set bwidth  (python -c "print(int($bsize*1.32))")
                sed -i "24s/.*/ButtonHeight=$bsize/" $rcdir
                sed -i "30s/.*/ButtonSpacing=0/" $rcdir
                sed -i "31s/.*/ExplicitButtonSpacer=2/" $rcdir
                sed -i "25s/.*/ButtonWidth=$bwidth/" $rcdir
            else
                sed -i "24s/.*/ButtonHeight=$bsize/" $rcdir
                sed -i "25s/.*/ButtonWidth=$bsize/" $rcdir
                sed -i "30s/.*/ButtonSpacing=10/" $rcdir
                sed -i "31s/.*/ExplicitButtonSpacer=10/" $rcdir
            end
        end
        #Modify the rc file accordingly
        zenity --question --text='Reload Kwin?'
        if test $status -eq 0
            setsid kwin_x11 --replace
        end
    end
end
