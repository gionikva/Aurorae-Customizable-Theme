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
set bthlist BT1 BT2 BT3 BT4 BT5 BT6
while not test $stat -eq 10
    set stati (yad --form --columns=1 --field=Customize:FBTN "fish -c \"echo 1 && killall yad\"" --field=Save\ Profile:FBTN "fish -c \"echo 2 && killall yad\"" --field=Load\ Profile:FBTN "fish -c \"echo 3 && killall yad\"" --button=Apply\ Changes:"fish -c \"echo 5 && killall yad\"" --button=Exit:"fish -c \"echo 10 && killall yad\"" --center)
    if test $status -eq 252
        exit
    end
    #Switch statement
switch $stati
case 1
    set l (count $bthlist)
    for i in (seq $l)
        if test $selection = $bthlist[$i]
            set bthlist[$i] "^$bthlist[$i]"
        end
    end
    set val1 $bthlist[1]
    for i in $bthlist[2..-1]
        set val1 "$val1!$i"
    end
    set opval (python -c "print(int($opac*100))")
    set val (yad --form --center --field="Button Theme":CB $val1 --field="Set Opacity":SCL --field="Set Button Size":SCL $opval $bsize --field="Choose Color":CLR --separator=\n --mode=rgb $color  --item-separator=!)
    set isempty 0
    for i in (seq 4)
        if test -z $val[$i]
            set -g isempty 1
        end
    end
    if not test $isempty -eq 1
        set ct1 (string sub $val[4] -s 4)
        set colort (python -c "print('#%02x%02x%02x' % $ct1)")
        set opac (python -c "print($val[2] / 100)")
        set bsize $val[3]
        set selection $val[1]
        set color $val[4]
    end
    case 2
        set sfile (yad --file --save --center)
        echo Opacity:\n$opac\nColor:\n$color\nButton Theme:\n$selection\nButton Size:\n$bsize | cat > "$sfile.actp"
    #Load profile
    case 3
        set lfile (yad --file --center)
        set -g opac (sed '2q;d' $lfile)
        set -g color (sed '4q;d' $lfile)
        set -g selection (sed '6q;d' $lfile)
        set -g bsize (sed '8q;d' $lfile)
        set ct1 (sed '4q;d' $lfile)
        set -g colort (python -c "print('#%02x%02x%02x' % $ct1)")
    #Quit script
    case 10
        exit
    #Apply Changes
    case 5
        set -g stat 10
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
        yad --question --text='Reload Kwin?' --center --width=200 --height=120 --button=No:1 --button=Yes:0 --text-align=center --window-icon=/usr/share/icons/breeze/status/64/dialog-question.svg --image=/usr/share/icons/breeze/status/64/dialog-question.svg
        if test $status -eq 0
            setsid kwin_x11 --replace
        end
    end
end
