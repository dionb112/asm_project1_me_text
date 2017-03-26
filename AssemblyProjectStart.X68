*-------------------------------------------------------
*First Submission. Second submission due Friday 31st March @ 5pm
*Dion Buckley
*C00220868
*December - March 2017
*Mass Effect RPG
*No Known Bugs - just some messages that could do with secondary counterparts to more perfectly reflect the choices made by player
*Time Taken: 30 - 42 hours approx
*-------------------------------------------------------
    ORG    $1048            ;program starts here to leave maximum room for each resource to be stored. If I store the resources after the programm somewhere, I ran into the issue of eventually later in the 
                            ;game, that some of the strings were being stored in the same memory locations, since I have so many. So this is the simple fix.
START:                      ; first instruction of program
    move   #900, $1000      ;credit resource in start
    lea    $1000, A2
    move   #250 , $1008     ;cost of new N5 crew member   
    lea    $1008, A3
    move   #0   , $1016     ;number of crew under your command
    lea    $1016, A4
    move   #100 , $1032     ;player health
    lea    $1032, A5
    move   #1   , $1040     ;this will later store and check who got sent to cover
    lea    $1040, A6
    
    bra    first
*-------------------------------------------------------
*-------------------Welcome Screen----------------------
*------------------------------------------------------- 
first
    lea     splash,A1
    bsr     display
    lea     welcome,A1
    bsr     display
    bsr     pause 
    bra     preparing  
*-------------------------------------------------------
*-------------------Resource Management-----------------
*-------------------------------------------------------
preparing
    bsr     clr_scrn
    lea     rm1,A1         
    bsr     display
    bsr     endl 
    
    lea     rm1b,A1         
    bsr     display
    bsr     endl
    
    lea     rm2,A1
    bsr     display          
    bsr     endl
    
    lea     rm3,A1
    bsr     display 
    bsr     endl 
    
    lea     rm4,A1
    bsr     display
    lea     rm5,A1
    bsr     display
    bsr     pause
    bsr     clr_scrn
        
loopPoint 
    lea     rm6,A1
    bsr     display
    bsr     endl
    
    bsr     input
    cmp     #0,D1                   ;if less or equal to 0 one type of error
    ble     chose0
    bra     resource                ;otherwise go and compute if player can actually afford that many units
    
chose0    
    bsr     clr_scrn                 
    lea     error3,A1       
    bsr     display         
    bsr     endl
    bne     loopPoint 
          
continue 
    
    cmp     #0,(A4)                 ;This little check is to simply get the correct message. If they still have 0 soldiers go back to that point
    beq     loopPoint               ;whereas if they already have at least 1 they can be asked if they would like another
                                    ;seems small but I've done a lot of this type of stuff throughout the project, trying to make it polished.
    cmp     #300,(A2)
    blt     lowCredits                           
    lea     rm7,A1
    bsr     display
    bsr     endl
 
    lea     rm8,A1
    bsr     display
    bsr     endl

    lea     rm9,A1
    bsr     display
    bsr     endl 
    
    bsr     input
    cmp     #1,D1
    beq     loopPoint2
    cmp     #2,D1
    beq     introClr

    
    bsr     clr_scrn  
    lea     error2,A1
    bsr     display           
    bsr     endl           
    bne     continue

loopPoint2
    bsr     clr_scrn
    bsr     endl

    lea     rm10,A1
    bsr     display
    bsr     endl
    
    bsr     input
    cmp     #0,D1
    ble     chose0
    cmp     #4,D1
    bra     resource

lowCredits
    lea     rm11,A1
    bsr     display
    bsr     pause
    bsr     clr_scrn
    bra     intro
   
resource
    move    D1,D4               ;storing how many crew members the player has entered before multiplying
    
    move    (A3),D3
    muls     D1,D3
    move    (A2),D5
    cmp     D5,D3 
 
    bls     buy
    bgt     tooMany

buy
    sub     D3,D5
    move    D5,$1000
    lea     $1000,A2
    move    (A4),D3 
    add     D4,D3
    move    D3,$1016
    lea     $1016,A4
    
    bsr     clr_scrn   
    bra     continue    

tooMany
    bsr     clr_scrn    
    lea     error4,A1
    bsr     display
    bsr     endl
    bra     continue

*-------------------------------------------------------
*--------------HUD (Heads up Display) STUFF--------------
*-------------------------------------------------------   
displayHUD
    clr.l   D1              ;without clearing the entire 8 bits of D1s memory we can get garbage in here if player enters massive numbers for input (or minus numbers for unsigned input)
    lea     remCred ,A1
    move    (A2),D1
    move    #17,D0
    trap    #15
    
    lea     crew ,A1
    move    (A4),D1
    move    #17,D0
    trap    #15
    
    lea     health ,A1
    move    (A5),D1
    move    #17,D0
    trap    #15
    
    cmp     #100,(A5)       ;this is a simple check if the health is 100 display one type of final '|' to finish that hud line, otherwise another type with an extra space
    beq     awkward1        ;this is an akward way for making a hud and it accounts for the fact that 100 is an extra digit than other hp numbers player can have (10-99)
    cmp     #9,(A5)         ;finally to make it even more awkward, when the player drops to single digit health we need one more space in that hud element.
    ble     awkward3        ;there is definitely more effecient ways of making a HUD but for these purposes it works, for now :)  
    bra     awkward2    
awkward1
    lea     awkwardHud,A1
    bsr     display
    bra     bottom
awkward2
    lea     awkwardHud2,A1
    bsr     display
    bra     bottom
awkward3
    lea     awkwardHud3,A1
    bsr     display
    bra     bottom
bottom
    lea     bottomHud,A1
    bsr     display
    bsr     endl
    rts
*-------------------------------------------------------
*-------------------Dream Sequence----------------------
*-------------------------------------------------------
introClr
    bsr clr_scrn
intro                   ;this is the first loop of the game
    lea m1_1,A1         ;display strings to tell the story
    bsr display    
    lea m1_2,A1
    bsr display
    bsr endl            ;extra line breaks used sometimes to split things up
             
    lea m1_3,A1
    bsr display  
    lea m1_4,A1
    bsr display
    bsr endl
   
    bsr input           ;here player is presented with two options, simple right?
    cmp #1,D1           ;I compare their choice with labeled options
    beq investigate     ;depending on which they picked it will branch appropriately
    
    cmp #2,D1
    beq still
    
    bsr clr_scrn        ;clear screen to tidy up            
    lea error1,A1       ;however if they decide to be cheeky and enter something else
    bsr display         ;they will get an error message
    bsr endl
    bne intro           ;and this branch will loop back to the top until they actually choose

investigate
    bsr clr_scrn
    lea m1_5,A1
    bsr display
    lea m1_6,A1
    bsr display
    bsr endl
    
    lea m1_7,A1
    bsr display
    bsr endl
    
    lea m1_8,A1
    bsr display
    lea m1_9,A1
    bsr display    
    lea m1_10,A1
    bsr display
    bsr endl
    
    lea m1_11,A1
    bsr display
    bsr endl
    
    lea m1_12,A1
    bsr display
    
    bsr pause               ;you will see I sometimes branch to the pause subroutine so I can 'pause' the window
    bsr clr_scrn
    bra end_dream           ;the user will simply have to press enter to continue
    
still
    bsr clr_scrn
    lea m1_13,A1
    bsr display    
    lea m1_14,A1
    bsr display
    lea m1_15,A1
    bsr display
    lea m1_16,A1
    bsr display
    lea m1_17,A1
    bsr display
    lea m1_18,A1
    bsr display
    lea m1_19,A1
    bsr display
    lea m1_20,A1
    bsr display
    bsr endl
    
    lea m1_21,A1
    bsr display
    bsr endl
    lea m1_22,A1
    bsr display
    lea m1_23,A1
    bsr display
    
    bsr pause 
    bsr clr_scrn
    bra end_dream
*-------------------------------------------------------
*-------------------Bed Sequence------------------------
*-------------------------------------------------------
end_dream                    ;second choice loop
    lea m1_24,A1
    bsr display
    lea m1_25,A1
    bsr display
    lea m1_26,A1
    bsr display
    lea m1_27,A1
    bsr display
    lea m1_28,A1
    bsr display
    bsr endl
    
    lea m1_29,A1
    bsr display
    lea m1_30,A1
    bsr display
    lea m1_31,A1
    bsr display
    bsr endl
    
    bsr input                ;this time the player has 3 options
    cmp #1,D1           
    beq lazy
    
    cmp #2,D1
    beq slow_riser
    
    cmp #3 ,D1
    beq out_of_bed
    
    bsr clr_scrn                  
    lea error2,A1           ;assuming the kind of person to not understand the concept of entering
    bsr display             ;a viable option at this stage is either trying to break the game or not that smart
    bsr endl                ;so i'll progress the error sarcasm.
    bra end_dream           

lazy:
    bsr clr_scrn
    lea lazyMsg,A1
    bsr display
    bsr pause
    bsr gameOver
    
lazy2:
    bsr clr_scrn
    lea m1_24,A1
    bsr display
    lea snooze2,A1
    bsr display
    lea m1_24,A1
    bsr display
    lea snooze3,A1
    bsr display
    lea snooze5,A1
    bsr display
    bsr endl
    
    bsr input           
    cmp #1,D1           
    beq lazy
    
    cmp #2,D1
    beq slow_riser2
    
    cmp #3 ,D1
    beq out_of_bed
    
    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra lazy2           
        
    
slow_riser
    bsr clr_scrn
    lea snooze,A1
    bsr display
    bsr input
    
    cmp #1,D1           
    beq out_of_bed
    
    cmp #2,D1
    beq lazy2

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra slow_riser    

slow_riser2
    bsr clr_scrn
    lea snooze4,A1
    bsr display
    bsr input
    
    cmp #1,D1           
    beq out_of_bed
    
    cmp #2,D1
    beq lazy2

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra slow_riser2
    
out_of_bed
    bsr clr_scrn
    lea snooze1,A1
    bsr display
    
    lea arrival,A1
    bsr display
    bsr pause
    bsr clr_scrn
*-------------------------------------------------------
*-------------------Meet the Crew-----------------------
*-------------------------------------------------------
meetSarah
    lea meet,A1
    bsr display
    bsr endl
    bsr input
    cmp #1,D1           
    beq choseMeet1
    
    cmp #2,D1
    beq choseMeet2
    
    cmp #3,D1
    beq choseMeet3

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra meetSarah

choseMeet1
    bsr clr_scrn                  
    lea meet1,A1
    bsr display
    bra checkCrewCount

choseMeet2
    bsr clr_scrn                  
    lea meet2,A1
    bsr display
    bra checkCrewCount
    
choseMeet3
    bsr clr_scrn                  
    lea meet3,A1
    bsr display
    bra checkCrewCount
    
checkCrewCount
    cmp #1,(A4)             ; if one crew just meet sarah
    beq justTheTwoOfUs   
    bra threesCompany       ;else meet jake next

    
justTheTwoOfUs
    lea crew1,A1
    bsr display
    bra angea    
    
threesCompany
    lea crew2,A1
    bsr display
    cmp #3,(A4)             ;finally if 3 crew go and meet hank
    beq foursCrowd
    bra angea               ;else continue
        
foursCrowd
    bsr endl
    lea crew3,A1
    bsr display
    bra angea
*-------------------------------------------------------
*-------------------Mission Begins----------------------
*-------------------------------------------------------
angea   
    bsr pause
    bsr clr_scrn 
    lea angeaMsg,A1
    bsr display
    
    bsr pause
    bsr clr_scrn
    cmp #3,(A4)         ;This whole branch will be a suprise for only those who took 3 crew
    beq hankDown
    bra squadGo

*-------------------------------------------------------
*-------------Coward ending posibility brach------------
*-------------------------------------------------------  
hankDown
    sub #1,(A4)  
hankDies
    lea ripHankMsg,A1
    bsr display
 
    
    bsr input
    cmp #1,D1           
    beq squadGo
    
    cmp #2,D1
    beq closeDoor

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra hankDies

closeDoor
    bsr clr_scrn                  
    lea shutDoorMsg ,A1
    bsr display   
    
    bsr input
    cmp #1,D1           
    beq squadGo
    
    cmp #2,D1
    beq coward

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra closeDoor
    
coward 
    bsr clr_scrn
    lea cowardMsg,A1
    bsr display
    bsr pause
    bsr gameOver
*-------------------------------------------------------
*---------Commanding troops in the heat of moment-------
*-------------------------------------------------------
squadGo
    bsr clr_scrn                  
    lea squadGoMsg,A1
    bsr display
    bsr pause
    bsr clr_scrn
    cmp #1,(A4)         ;now that hank will be dead we can make choices based on having 1 crew or either other option
    beq coverIf1
    bra coverElse

coverIf1
    lea cover1,A1
    bsr display   
    
    bsr input
    cmp #1,D1           
    beq solo
    
    cmp #2,D1
    beq noCover

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra coverIf1

coverElse
    lea cover2,A1
    bsr display
    
    bsr input
    cmp #1,D1           
    beq twoCover
    
    cmp #2,D1
    beq wSarah
    
    cmp #3,D1
    beq wJake
    
    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra coverElse

twoCover
    move #1,(A6)            ;storing that both went to cover
    
    bsr clr_scrn
    lea twoCoverMsg,A1
    bsr display 
    bsr endl
    bsr pause
    bsr clr_scrn
    bra fightStart 
wJake
    move #2,(A6)            ;storing that sarah went to cover

    bsr clr_scrn
    lea wJakeMsg,A1
    bsr display 
    bsr endl
    bsr pause
    bra ripSarah 
wSarah                      ;Jake die message included so no need to store
    bsr clr_scrn
    lea wSarahMsg,A1
    bsr display 
    bsr endl
    bsr pause
    bra ripJake
    
ripJake
    bsr clr_scrn
    lea ripJakeMsg,A1
    bsr display 
    bsr endl
    sub     #1,(A4)
    bra battleEnd 
ripSarah
    bsr clr_scrn
    lea ripSarahMsg,A1
    bsr display 
    bsr endl
    sub     #1,(A4)
    bra battleEnd     
noCover
    bsr clr_scrn                  
    lea noCoverMsg,A1
    bsr display
    bsr pause
    bsr clr_scrn                  
    bra fightStart

solo
    move #2,(A6)                                        ;storing that sarah went to cover

    bsr clr_scrn                  
    lea soloMsg,A1
    bsr display
    bsr pause
    bsr clr_scrn                  
    bra fightStart
*------------------------------------------------------- ;This whole fight is only available if the player ends up in the building solo.
*--------------1 on 1 FIGHT sequence-------------------- ;adds dificulty so they will needed to have good squad commands to provide cover.       
*------------------------------------------------------- ;Also needed enough squad to make it here with a member to help. adds depth / replay value
fightStart
    lea fightMsg,A1
    bsr display
  
    bsr input
    cmp #1,D1           
    beq tackle
    
    cmp #2,D1
    beq aim

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra fightStart
*-------------------------------------------------------
*-------------------Winning the fight-------------------
*-------------------------------------------------------
tackle
    bsr clr_scrn                  
    lea tackleMsg,A1
    bsr display
    bsr pause
    bsr clr_scrn                  
winning
    lea winningMsg,A1
    bsr display
    
    bsr input
    cmp #1,D1           
    beq kick
    
    cmp #2,D1
    beq gunDown

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra winning

kick
    bsr healthDown
    bsr clr_scrn                  
    lea kickMsg,A1
    bsr display
    bsr pause 
    bsr clr_scrn                  
    bra even
    
gunDown
    bsr clr_scrn                  
    lea gunDownMsg,A1
    bsr display
    bsr pause 
    bsr clr_scrn
    bra checkCover
*-------------------------------------------------------
*-------------------Losing the fight--------------------
*-------------------------------------------------------
aim
    bsr healthDown
    bsr clr_scrn                  
    lea aimMsg,A1
    bsr display
    bsr pause
    bsr clr_scrn                  
losing    
    lea losingMsg,A1
    bsr display

    bsr input
    cmp #1,D1           
    beq counter
    
    cmp #2,D1
    beq escape

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra losing
    
counter
    bsr clr_scrn                  
    lea counterMsg,A1
    bsr display
    bsr pause 
    bsr clr_scrn                  
    bra even
    
escape
    bsr healthDown
    bsr clr_scrn                  
    lea escapeMsg,A1
    bsr display
    bsr pause 
    bra gameOver

*-------------------------------------------------------
*-------------------Even fight--------------------------
*-------------------------------------------------------        
even    
    lea evenMsg,A1
    bsr display

    bsr input
    cmp #1,D1           
    beq rush
    
    cmp #2,D1
    beq hold

    bsr clr_scrn                  
    lea error2,A1       
    bsr display         
    bsr endl
    bra even
    
rush
    bsr clr_scrn                  
    lea rushMsg,A1
    bsr display
    bsr pause 
    bra gameOver
    
hold
    bsr clr_scrn                  
    lea holdMsg,A1
    bsr display
    bsr pause 
    bra checkCover

checkCover
    cmp #1,(A6)
    beq twoDeath
    cmp #2,(A6)
    beq ripSarah
    bra battleEnd

twoDeath
    bsr clr_scrn
    lea twoDeathMsg,A1
    bsr display
    bsr endl
    sub     #2,(A4)
  
battleEnd
    bsr pause
    bsr clr_scrn
    lea endOfBattle,A1
    bsr display 
    bsr pause
    bsr clr_scrn
    bra legion

legion
    lea legionMsg,A1
    bsr display 
    bsr pause
    bsr gameOver
*-------------------------------------------------------
*-------------------EXIT GAME---------------------------
*-------------------------------------------------------    
exit:
    bsr clr_scrn
    lea goHome,A1
    bsr display
    SIMHALT             ;halt simulator
    
*-------------------------------------------------------
*-------------------Utility Subroutines-----------------
*-------------------------------------------------------
clr_scrn
    move #$FF00, d1     ;clear screen
    move #11, d0        ;position cursor
    trap #15
    bsr  displayHUD
    rts
endl
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts

display           
    move    #14,D0      ;display the string from A1
    trap    #15         ;to screen
    bsr     endl        ;branch to endline
    rts
    
input
    bsr     endl
    move    #4,D0       ;Read number from keyboard into D1
    trap    #15  
    bsr     endl   
    rts
 
pause
    bsr     endl
    lea     cont,  A1
    bsr     display
    move    #4,     D0  ;Read number from keyboard into D1
    trap    #15
    bsr     endl     
    rts   
    
gameOver
    bsr     clr_scrn
    lea     over,A1
    bsr     display
    bsr     input
    cmp     #1,D1
    beq     START
    cmp     #2,D1
    beq     exit
    
    bsr     clr_scrn
    lea     error2,A1
    bsr     display
    bra     gameOver

healthDown
    sub     #50,(A5)    ;poor player decisions in the big 1v1 fight will result in losing half hp
    rts   
*-------------------------------------------------------
*-------------------Data Declarations-------------------
*-------------------------------------------------------    
crlf	    dc.b	$0d,$0a,0
cont        dc.b    '[Press Enter to continue]',0
goHome      dc.b    '[What are you still doing here?.. The game is over.. play it again already!]',0                  ; cute 'after credits' message
  
*-------------------Game Over---------------------------
over        dc.b    '...............................................................................',$D,$A
            dc.b    ' _______   ________  ___ __ __  ______     ______  __   __  ______  ______       ',$D,$A
            dc.b    '/______/\ /_______/\/__//_//_/\/_____/\   /_____/\/_/\ /_/\/_____/\/_____/\      ',$D,$A
            dc.b    '\::::__\/_\::: _  \ \::\| \| \ \::::_\/_  \:::_ \ \:\ \\ \ \::::_\/\:::_ \ \     ',$D,$A
            dc.b    ' \:\ /____/\::(_)  \ \:.      \ \:\/___/\  \:\ \ \ \:\ \\ \ \:\/___/\:(_) ) )_   ',$D,$A
            dc.b    '  \:\\_  _\/\:: __  \ \:.\-/\  \ \::___\/_  \:\ \ \ \:\_/.:\ \::___\/\: __ `\ \  ',$D,$A
            dc.b    '   \:\_\ \ \ \:.\ \  \ \. \  \  \ \:\____/\  \:\_\ \ \ ..::/ /\:\____/\ \ `\ \ \ ',$D,$A
            dc.b    '    \_____\/  \__\/\__\/\__\/ \__\/\_____\/.  \_____\/\___/_(  \_____\/\_\/ \_\/ ',$D,$A
            dc.b    '................................................................................',$D,$A
            dc.b    '  _   _                    _            _           _       _          ',$D,$A
            dc.b    ' / | | |_ ___   _ _ ___ __| |_ __ _ _ _| |_   _ __ (_)_____(_)___ _ _  ',$D,$A
            dc.b    ' | | |  _/ _ \ | ''_/ -_|_-<  _/ _` | ''_|  _| | ''  \| (_-<_-< / _ \ '' \ ',$D,$A
            dc.b    ' |_|  \__\___/ |_| \___/__/\__\__,_|_|  \__| |_|_|_|_/__/__/_\___/_||_|',$D,$A
            dc.b    '................................................................................',$D,$A
            dc.b    '  ___   _          ___       _ _      ___                ',$D,$A
            dc.b    ' |_  ) | |_ ___   / _ \ _  _(_) |_   / __|__ _ _ __  ___ ',$D,$A
            dc.b    '  / /  |  _/ _ \ | (_) | || | |  _| | (_ / _` | ''  \/ -_)',$D,$A
            dc.b    ' /___|  \__\___/  \__\_\\_,_|_|\__|  \___\__,_|_|_|_\___|',$D,$A
            dc.b    '................................................................................',0
*-------------------Welcome Screen----------------------
welcome     dc.b    'In the wake of the attack on the Citadel, led by Sovereign and an indoctrinated',$D,$A
            dc.b    'Saren, the Council has dispatched the SSV Normandy ship and its crew to clean up  ',$D,$A
            dc.b    'the remaining geth. These surviving geth, who upon failing in their attempts to  ',$D,$A  
            dc.b    'help Saren bring back the Reapers, have fled to the Terminus System. Here they ',$D,$A
            dc.b    'hope to regroup and recover. ',$D,$A,$D,$A
            dc.b    'You will play as the spectre, John Shepard, commanding a crew aboard the',$D,$A
            dc.b    'Normandy. However, the majority of your original crew have gone their own way ',$D,$A
            dc.b    'for now, seeking some respite. So you must use what little budget the council ',$D,$A
            dc.b    'has allowed you for this  mission to recruit some soldiers fresh out of the N7 ',$D,$A
            dc.b    'training programme. Being that the geth forces are at their lowest point in ',$D,$A
            dc.b    'history, these soldiers should more than suffice.',0

splash      dc.b    '     _____                         ___________ _____  _____             __   ',$D,$A
            dc.b    '    /     \ _____    ______ ______ \_   _____// ____\/ ____\____  _____/  |_ ',$D,$A
            dc.b    '   /  \ /  \\__  \  /  ___//  ___/  |    __)_\   __\\   __\/ __ \/ ___\   __\',$D,$A
            dc.b    '  /    Y    \/ __ \_\___ \ \___ \   |        \|  |   |  | \  ___|  \___|  |  ',$D,$A
            dc.b    '  \____|__  (____  /____  >____  > /_______  /|__|   |__|  \___  >___  >__|  ',$D,$A
            dc.b    '  .__     \/     \/   __\/     \/    __    \/         .__      \/    \/      ',$D,$A
            dc.b    '  |  |   ____  ______/  |_    ______/  |_  ___________|__| ____   ______ /\  ',$D,$A
            dc.b    '  |  |  /  _ \/  ___|   __\  /  ___|   __\/  _ \_  __ \  |/ __ \ /  ___/ \/  ',$D,$A
            dc.b    '  |  |_(  <_> )___ \ |  |    \___ \ |  | (  <_> )  | \/  \  ___/ \___ \  /\  ',$D,$A
            dc.b    '  |____/\____/____  >|__|   /____  >|__|  \____/|__|  |__|\___  >____  > \/  ',$D,$A
            dc.b    '    ________      \/__  .__      \/___ ___               __   \/     \/      ',$D,$A
            dc.b    '   /  _____/  _____/  |_|  |__    /   |   \ __ __  _____/  |_                ',$D,$A
            dc.b    '  /   \  ____/ __ \   __\  |  \  /    ~    \  |  \/    \   __\               ',$D,$A
            dc.b    '  \    \_\  \  ___/|  | |   Y  \ \    Y    /  |  /   |  \  |                 ',$D,$A
            dc.b    '   \______  /\___  >__| |___|  /  \___|_  /|____/|___|  /__|                 ',$D,$A
            dc.b    '          \/     \/          \/         \/            \/                     ',$D,$A,0

*-------------------Resource Management-----------------
rm1         dc.b    '[You will need to form a team of at least 1 crew, to help you on your mission!]',0
rm1b        dc.b    '[The choices you make, ranging from how many crew you take, to exactly how you]',$0D,$0A
            dc.b    '[command those crew members within the game will GREATLY change your gameplay]',$0D,$0A
            dc.b    '[oppotunities. I would highly recommend playing through this game a few times!]',0    
rm2         dc.b    '[Each trained N7 soldier will run 250 credits from your commanding budget.]',0
rm3         dc.b    '[You start out the game with a budget of 900 credits.]',0
rm4         dc.b    '[You may FIND some credits on your missions but be careful, as if a team- ',0
rm5         dc.b    ' member dies on a mission you may have to get more before the next mission.]',0
rm6         dc.b    '[How many team members will you add to the crew before the first mission?]',$0D,$0A
            dc.b    '(250 credits each)',0
rm7         dc.b    '[Would you like to hire any more N7s before this mission?(250 credits each)]',0
rm8         dc.b    '1.[Yes, I need as much help as I can get.] ',0    
rm9         dc.b    '2.[No, I only really hired that one member because you made me anyway.]',0  
rm10        dc.b    '[How many additional soldiers do you require today?(300 credits each)]',0  
rm11        dc.b    '[It seems like you are too low on credits to afford any more soldiers!]',$D,$A
            dc.b    '[Come back when you have earned more credits!]',$D,$A,$D,$A
            dc.b    'Broke, and fully teamed up, you feel ready, no, excited even, to go and hunt',$D,$A 
            dc.b    'down any remaining Geth hideouts in the Terminus System. [Best of luck!]',0
remCred     dc.b    '  ____________________________________________________________________________',$D,$A
            dc.b    ' |                           |                               |                | ',$D,$A      
            dc.b    ' |Remaining Credits: ',0
crew        dc.b    '     | Crew under your command: ',0
health      dc.b    '    | Health: ',0
awkwardHud  dc.b    '    |',0
awkwardHud2 dc.b    '     |',0      
awkwardHud3 dc.b    '      |',0      
bottomHud   dc.b    ' |___________________________|_______________________________|________________| ',0   

*Validation of entered Data*
error1      dc.b    '[Psst.. You see those choices you were just given? Try picking one this time..]',0
error2      dc.b    '[Have you really not figured out how to just choose an option yet? Try again..]',0
error3      dc.b    '[Now that you''ve come this far, you feel compelled to enlist at least one N7..]',0
error4      dc.b    '[You do not have enough credits to hire that many soldiers..]',0


*-------------------Mission 1--------------------------- ;At the start you can see my early days of putting everythign in strings, compared to how I learned and progressed. Easier for now to leave how is. Apply in future
*Start*
m1_1        dc.b    'You find yourself in a dark forest, with Erie sounds rustling through the trees.',0
m1_2        dc.b    'A mysterious voice calls out to you: "Commander.. Commander!"',0
m1_3        dc.b    '1.[Investigate]',0
m1_4        dc.b    '2.[Stay perfectly still]',0
*Investigate*
m1_5        dc.b    'You wade through the shadows, to find a soldier sitting on the ground,',0
m1_6        dc.b    'littered with blood, staring away from you.',0
m1_7        dc.b    'Voice: "Do you even remember me Commander Shepard?..."',0
m1_8        dc.b    'The figure turns around, revealing a face you almost recognise. It takes you a',0 
m1_9        dc.b    'moment but when the penny drops you can feel your entire world spin instantly.',0
m1_10       dc.b    'Here before you, beneath all the blood and scars lies Ashley Williams.',0
m1_11       dc.b    'Ashley: "You did this to me.. Commander.. You''re no hero. You''re a damn monster!"',0
m1_12       dc.b    'Ashley pulls out her military grade dagger and lunges forward straight for you.',0
*Still*
m1_13       dc.b    'The voice seems to circle around you now, as you stand there, helpless.',0
m1_14       dc.b    'The more the voice wraps around you, the more you drift into fear until you ',0 
m1_15       dc.b    'actually cannot move at all. Paralyzed now, you watch now as the shadows ',0
m1_16       dc.b    'start to dance around you, almost toying with you. Time seems to stand still ',0
m1_17       dc.b    'and just when you begin to think you have lost your mind, you see something  ',0
m1_18       dc.b    'glint from within the shadows. As the glint fast encroaches upon you a figure  ',0
m1_19       dc.b    'begins to form around it. Finally you can just make out a face, ',0
m1_20       dc.b    'and it''s none other that of Ashley Williams.',0
m1_21       dc.b    'Ashley: "You left me to die on Virmire! Did I mean NOTHING to you?!"',0
m1_22       dc.b    'With that she lunges forward. You look down just in time to see that the glint',0
m1_23       dc.b    'has taken the form of a dagger and just as it''s about to pierce your chest..',0
*End of Dream*
m1_24       dc.b    'NNNRRRGGG! NNNRRRGGG! NNNRRRGGG!',0
m1_25       dc.b    'You almost jump a foot out of your bed at that painfully familiar sound.',0    
m1_26       dc.b    'NNNRRRGGG! NNNRRRGGG! NNNRRRGGG!',0    
m1_27       dc.b    '5AM?! What did I do to deserve this? You think. ',0    
m1_28       dc.b    'NNNRRRGGG! NNNRRRGGG! NNNRRRGGG!',0    
m1_29       dc.b    '1.[Turn off the alarm returning to.. hopefully not another nightmare] ',0    
m1_30       dc.b    '2.[Snooze the alarm proceeding to become semi-concious over the coming minutes]',0    
m1_31       dc.b    '3.[Be the ''morning'' person that you are and hop out of bed with glee] ',0   
 
*Lazy*   
lazyMsg     dc.b    'I''ve been working myself too hard recently, what with chasing around the galaxy',$D,$A
            dc.b    'after Saren, putting a halt to Sovereigns plan to bring back the Reapers, and',$D,$A
            dc.b    'pretty much just saving everyone. Plus the Geth are on the run. I can afford to ',$D,$A
            dc.b    'take one morning as a lye in. Right?',$D,$A,$D,$A
            dc.b    'You shut off the alarm and drift back into a blissful slumber..................',$D,$A
            dc.b    '...............................................................................',$D,$A,$D,$A
            dc.b    'You are jolted awake as the turbulance throws you from your bed. Unusual, ',$D,$A
            dc.b    'Joker would never usually handle the Normandy like this..',$D,$A
            dc.b    'Alarms begin to pierce your ears, accompanied by flashing red lights',$D,$A
            dc.b    'You rush from your Commanders quarters to find out what in the hell is going on.',$D,$A
            dc.b    'The door of your quarters opens just in time for you to witness, in what feels',$D,$A
            dc.b    'now like an eternity frozen in time, giant beams of energy rip the through',$D,$A
            dc.b    'the ship, one after another in quick succession.',$D,$A,$D,$A
            dc.b    'Before you even have time to react the ship is split in two and you are blasted',$D,$A
            dc.b    'off into the deep, dark, abyss of space...',$D,$A,$D,$A

            dc.b    '[It seems that without their Commander around, your crew never went on that    |',$D,$A
            dc.b    '|Geth hunting mission. Favoring instead, on waiting for further commands from  |',$D,$A
            dc.b    '|their lazy Commander. They were left as sitting ducks in the Terminus         | ',$D,$A
            dc.b    '|System. So it didn''t take long for.. who or whatever that was, to find them  ]',$D,$A,0
        
*Snooze*
snooze      dc.b    'You lay in your bed for a little while, piecing together fragments of your mind.',$D,$A
            dc.b    'Your heart is still racing from that crazy dream.. "Why can''t I just forget?"..',$D,$A 
            dc.b    'Do you find yourself sufficiently concious and ready to hunt some Geth yet?',$D,$A 
            dc.b    '1.[There is no time to dwell on that dream, I have a squad to command!]',$D,$A 
            dc.b    '2.[With incoherent thoughts flying past my minds eye I drift back into a sleep.]',0 
snooze1     dc.b    'You wipe the sweat from your brow and with that you crawl out the bed and dress.',0 
snooze2     dc.b    'There''s that pesky alarm again.',0 
snooze3     dc.b    'Somehow you actually feel more tired now.',0
snooze4     dc.b    'There you lay, still trying to find that elusive mind of yours..',$D,$A
            dc.b    'Now do you find yourself sufficiently concious and ready to hunt some Geth?',$D,$A 
            dc.b    '1.[I guess I might aswel go kill some Geth..]',$D,$A 
            dc.b    '2.[I don''t want to play this game, I just want to sleep.]',0 
snooze5     dc.b    'NNNRRRGGG! NNNRRRGGG! NNNRRRGGG!',$D,$A 
            dc.b    '1.[This time the alarm is going off, fuck life, I''m done with snooze] ',$D,$A     
            dc.b    '2.[Surely snoozing the alarm with work better this time!]',$D,$A    
            dc.b    '3.[I guess that''s enough snoozing for me, up I get.] ',0
        
*Angea*
arrival     dc.b    'Just as the nostalgia rush which flows through you every time you finish putting ',$D,$A
            dc.b    'on your slightly outdated, but most used and favoured gear by far, your first ',$D,$A
            dc.b    'set of N7 armour, begins to wear off, a familiar voice comes to you from the',$D,$A
            dc.b    'intercom.',$D,$A,$D,$A
            dc.b    'Joker: "Did you have a good nap Commander? We are making our way through the ',$D,$A
            dc.b    'Omega Nebula now, we should reach the Amada System in exactly 7 minutes. Oh ',$D,$A
            dc.b    'and Commander, Those new recruits of yours, they''re waiting ever so patiently  ',$D,$A
            dc.b    'to meet you down in the cargo hold."',$D,$A,$D,$A
 
            dc.b    'With that you make your way down to meet your new recruits.',0

meet        dc.b    'Sarah: "Shepard! We were in a squad together way back when we were simple N3 ',$D,$A
            dc.b    'soldiers. Then you got promoted over and over leaving me behind. They made',$D,$A
            dc.b    'you the first human spectre I heard?! Crazy stuff! Well I almost caught up to  ',$D,$A
            dc.b    'you now that I''ve made it to N7 at least! Anyway I''m rambling again. You still ',$D,$A
            dc.b    'remember me right?"',$D,$A,$D,$A
            dc.b    'The woman sets a hand on her hip.',$D,$A,$D,$A
            dc.b    '1.["Yes, of course I remember you."]',$D,$A,$D,$A   
            dc.b    '2.["No, I don''t remember you."]',$D,$A,$D,$A
            dc.b    '3.["You will address me as, Sir, or Commander, from this point on."]',0
        
meet1       dc.b    'Sarah: "Good, I would have been pretty upset if you had forgotten little ''ole me.',0

meet2       dc.b    'Sarah sighs.',$D,$A,$D,$A        
            dc.b    'Sarah: "Of course you don''t. Why would you remember me? Your best friend from ',$D,$A
            dc.b    'seven years ago. Whatever, I''m not that surprised, it has been a long time,',$D,$A
            dc.b    'and you have been pretty busy.',0
        
meet3       dc.b    'Sarah stares at you.',$D,$A,$D,$A
            dc.b    'Sarah: "The one thing I feared has now happened, my first real friend has fallen ',$D,$A
            dc.b    'pray over the years to this bitter millitary mentality. How sad. Well, ''Sir''.. ',0
        
crew1       dc.b    'Regardless of all that, I just wanted to thank you for choosing me as your ',$D,$A
            dc.b    'sole recruit for this mission. Regardless how small of a mission, this really ',$D,$A
            dc.b    'means a lot to me, so I appreciate it and I won''t let you down"',0
        
crew2       dc.b    'Look at me hogging up all the spotlight like this, I know you must be itching',$D,$A
            dc.b    'to meet the second recruit so I''ll just wrap this up by telling you how much',$D,$A 
            dc.b    'it means to me to have been chosen for this mission. I will not let you down!',$D,$A,$D,$A
            dc.b    'You turn to the second person in the room, Who at this point, you notice has ',$D,$A
            dc.b    'been standing to attention the entire time. "At ease soldier.", you say to him.',$D,$A
            dc.b    'He relaxes somewhat',$D,$A,$D,$A
            dc.b    'Jake: "Thank you Commander. I''ll keep this short and sweet. My name is Jake ',$D,$A
            dc.b    'O'' Meara, I joined the Alliance the second I turned 18 and I''ve been grinding ',$D,$A
            dc.b    'my way up the ranks ever since. To be recruited by THE Commander Shepard for a ',$D,$A  
            dc.b    'mission is more than I could have ever dreamed of. This is the ultimate honour,',$D,$A
            dc.b    'you will not regret your decision!"',0
        
crew3       dc.b    'The third recruit seems to be staring off into middle distance.',$D,$A,$D,$A
            dc.b    'Sarah: "Oh, this fella? Well, this is Hank, he''s sort of the ''strong silent',$D,$A
            dc.b    'type''. Damn good engineer though!"',$D,$A,$D,$A            
            dc.b    'Hank seems to nod his head ever so slightly in agreement.',0       
        
angeaMsg    dc.b    'The young blood has definitely brought a good energy to the team, you now feel ',$D,$A
            dc.b    'instilled with a sense of confidence. Just then the comms line opens up again.',$D,$A,$D,$A
            dc.b    'Joker: "Stealth systems engaged, taking her in Commander."',$D,$A,$D,$A
            dc.b    'The Normandy hums along quick and quiet as you enter the green tinted atmosphere ',$D  ,$A
            dc.b    'of Angea. Hopefully this is the last distress call you will ever have receieved',$D,$A
            dc.b    'related to the geth. Head to Angea of the Amada System, take out any geth that ',$D,$A
            dc.b    'have been spotted here, head home in time for supper. How hard could it be?',$D,$A,$D,$A
            dc.b    'Joker: "Alright Commander, we are closing in on the coordinates of the distress ',$D,$A
            dc.b    'beacon. Prepare to disembark."',$D,$A,$D,$A
            dc.b    'Everything seems quiet as the Normandy pulls up to one of the landing pads. ',$D,$A,$D,$A
            dc.b    'You:	"We all know what we came here to do. This distress call is most ',$D,$A
            dc.b    'definitely a geth trap, and I hope it will be the last trap ever lay by geth  ',$D,$A
            dc.b    'hands. Let''s put an end to this abomination race one and for all today!" ',$D,$A,$D,$A
            dc.b    'The ship docks and the cargo bay doors open ',$D,$A
            dc.b    '["Go! Go! Go!"]',0
            
ripHankMsg  dc.b    'Hank: "For the Human Alliance!" ',$D,$A,$D,$A
            dc.b    'A sniper shot flies through Hank''s forehead, and he smashes into the side of  ',$D,$A
            dc.b    'the ship, painting it in blood. ',$D,$A,$D,$A
            
            dc.b    '1.["No time to mourn him now! Get moving N7s!"] ',$D,$A,$D,$A
            dc.b    '2.["This isn''t safe! Joker Shut the door!"] ',0

shutDoorMsg dc.b    'The door slams shut as Joker activates the air lock.',$D,$A,$D,$A
            dc.b    'Sarah: "What are you doing Commander?! We knew what we were getting into with ',$D,$A
            dc.b    'this mission, this needs to be done! Don''t let Hank''s death be in vain!"',$D,$A,$D,$A
            dc.b    '1.["You''re right, I don''t know what I was thinking! Get that door back open!"]',$D,$A,$D,$A
            dc.b    '2.["I won''t let any more of you recruits die today! Joker Get us out of here!"]',0
            
cowardMsg   dc.b    'The ships engines ignite with life, and the ship bolts into the sky.',$D,$A,$D,$A
            dc.b    'Joker: "Ah Commander.. It appears that the geth are charging up a rail gun! I ',$D,$A
            dc.b    'might be the best damn pilot in the galaxy, but the gravity from this planet is ',$D,$A
            dc.b    'too heavy for us to enter the atmosphere while also allowing for evasive ',$D,$A
            dc.b    'manoeuvres. I need a command now!',$D,$A,$D,$A
            dc.b    'At this stage you have already been far too indecisive to make clear headed and ',$D,$A
            dc.b    'fast commands. You hesitate for a moment longer. Just then the rail gun fires ',$D,$A
            dc.b    'off a devastating blue beam, vaporizing the once grand SSV Normandy, along ',$D,$A
            dc.b    'with everyone inside.',0
            
squadGoMsg  dc.b    'Your squad yells a battle cry as they sprint out of the ship onto the wet  ',$D,$A
            dc.b    'steel floor of the Geth base. On the main building directly in front of you,   ',$D,$A
            dc.b    'a manual turrey can be spotted up on the balcony. A Geth soldier jumps onto the  ',$D,$A
            dc.b    'turret and aims it at your squad. ',$D,$A,$D,$A
            dc.b    'You see the Normandy pull off as Joker takes her to a safe spot to wait out the  ',$D,$A
            dc.b    'mission. ',$D,$A,$D,$A
            dc.b    'You see two available cover spots. A building is to your left, and a metal  ',$D,$A
            dc.b    'barricade is on your right. ',0 

            
cover1      dc.b    '1.["Sarah, provide cover fire from that baricade, I''ll rush the building!"] ',$D,$A,$D,$A
            dc.b    '2.["Sarah, I need you with me. Let''s make a break for that building!"] ',0
            
cover2      dc.b    '1.["Sarah, Jake, provide cover fire from that baricade, I''m going in!"] ',$D,$A,$D,$A
            dc.b    '2.["Sarah, I need you with me. Jake, provide cover fire from that baricade!"] ',$D,$A,$D,$A       
            dc.b    '3.["Jake, I need you with me. Sarah, provide cover fire from that baricade!"] ',0     
   
soloMsg     dc.b    'Sarah: "Copy!"',$D,$A,$D,$A
            dc.b    'You make a dive for the building. As you stand up, you see Sarah pin herself ',$D,$A   
            dc.b    'up against the metal barricade.',0

noCoverMsg  dc.b    'Sarah: "Copy!"',$D,$A,$D,$A
            dc.b    'Sarah sprints to your side as you both make a rush for the building. You see ',$D,$A
            dc.b    'now that without anyone to provide you with cover fire, a squad of Geth',$D,$A
            dc.b    'Troopers has moved forward, unopposed, into position by the metal barricade. ',$D,$A
            dc.b    'They begin to fire their pulse rifles upon your position, a few shots zoom by ',$D,$A
            dc.b    'and then, one of the lasers flies through Sarah''s head, and she flies ',$D,$A
            dc.b    'backwards now to the ground, streaking blood across it as she slides. With no ',$D,$A
            dc.b    'time to stop and think about it now, you narrowly avoid the rest of the fire ',$D,$A
            dc.b    'as you just barely slip into the building unscathed.',0
            
fightMsg    dc.b    'A Geth Hopper launches through the door in an attempt to hook itself ',$D,$A
            dc.b    'onto your face. Alone now and with no safe way to go back, you must face this ',$D,$A
            dc.b    'guy head on.',$D,$A,$D,$A
            dc.b    '1.[I attempt to dodge the hook and tackle the Hopper to the floor.]',$D,$A,$D,$A
            dc.b    '2.[I take aim with my pistol and attempt to fire straight between the eyes.]',0
            
tackleMsg   dc.b    'In what feels almost like slow motion, you time your side step perfectly and ',$D,$A
            dc.b    'successfully tackle the Hopper, head, or whatever you might call that thing ',$D,$A
            dc.b    'the Geth have on their shoulders, first into the ground. ',$D,$A,$D,$A  
            dc.b    'You quickly follow up with a nasty elbow, cracking open its only ''eye''.',$D,$A   
            dc.b    'The Hopper manages to push you off now but as it staggers back to face you it ',$D,$A
            dc.b    'looks visibly weakened already. ',$D,$A,$D,$A
            dc.b    'You feel confident that the Hopper would not survive another mistake ',$D,$A
            dc.b    'like that. ',0
            
aimMsg      dc.b    'In what feels almost like slow motion, you raise you pistol to take perfect ',$D,$A
            dc.b    'aim for this shot. You take a fraction of a second too long however and the ',$D,$A
            dc.b    'Hopper is upon you before you get the chance to fire. It knocks you to the ',$D,$A
            dc.b    'ground and slashes at you with each of its hooked hands, one after another. ',$D,$A,$D,$A
            dc.b    'This action rips your face wide open in two places. You are definitely worse ',$D,$A
            dc.b    'for wear after that attack and you feel like you might not survive another ',$D,$A
            dc.b    'mistake like that. You do however, manage to regain some composure.',0
            
winningMsg  dc.b    'This Geth Hopper realises now that it is in fact losing this battle. With no ',$D,$A
            dc.b    'wish to die today it looks around for an escape path and makes an attempt to ',$D,$A
            dc.b    'bolt for the exit.',$D,$A,$D,$A
            dc.b    '1.[I attempt to cut off the escape and go for a stylish spin kick to finish!]',$D,$A,$D,$A
            dc.b    '2.[I take aim with my assault rifle and attempt to gun this coward down!]',0
            
losingMsg   dc.b    'This Geth Hopper realises now that is in fact winning this battle. With no ',$D,$A
            dc.b    'wish to wait around it launches quickly into a second attack. This time ',$D,$A
            dc.b    'springing first up to the ceiling above you where it hooks itself in for a ',$D,$A
            dc.b    'moment before springing directly down towards you to finish you off.',$D,$A,$D,$A
            dc.b    '1.[I react quickly by rolling to the side, following with a counter attack!]',$D,$A,$D,$A
            dc.b    '2.[I dive into a forward roll, looking for safety now that I have the chance!]',0
            
kickMsg     dc.b    'You are faster than the Hopper at this stage, as he is wounded and unable to ',$D,$A
            dc.b    'spring away with a long distance launch. However the last encounter has gone ',$D,$A
            dc.b    'to your head. With a little too much confidence you spring forward into a spin ',$D,$A
            dc.b    'kick, and aiming just a hair too high you miss. Your momentum sends you ',$D,$A
            dc.b    'spinning yourself to the ground. ',$D,$A,$D,$A  
            dc.b    'The Hopper notices this sloppy display.',$D,$A,$D,$A   
            dc.b    'Before you get the chance to pick yourself back up, it takes its chance and ',$D,$A   
            dc.b    'launches once more. This time it finds the mark and slashes at you with each ',$D,$A   
            dc.b    'of its hooked hands, one after another. This action rips your face wide open ',$D,$A   
            dc.b    'in two places. You are definitely worse for wear after that attack. At this ',$D,$A   
            dc.b    'stage, neither of you are looking great and you feel like this next skirmish ',$D,$A   
            dc.b    'will be the last for one of you. You do however, manage to regain some ',$D,$A   
            dc.b    'composure.',0
            
gunDownMsg  dc.b    'As this Geth attempts to scurry away in a pitiful attempt to save itself you ',$D,$A   
            dc.b    'take aim, feeling no pressure at this point and fire off an entire clip into ',$D,$A   
            dc.b    'its back. Not having received a single scratch you scoff at how easy that ',$D,$A   
            dc.b    'encounter was and press on forward.',0
            
counterMsg  dc.b    'You just barely manage to execute the dodge roll. Turning now with quick ',$D,$A   
            dc.b    'decisive action, you swing from the left and land a solid haymaker sending the ',$D,$A   
            dc.b    'Hopper flying across the room. You feel like you have successfully evened out ',$D,$A   
            dc.b    'this fight, starting to fill up with focus now you know that only one of you ',$D,$A   
            dc.b    'will walk away from this at this point.',0
            
escapeMsg   dc.b    'You just barely manage to execute the dodge roll. Using your momentum now you ',$D,$A   
            dc.b    'spring forward in an attempt to escape with your life. However you are ',$D,$A   
            dc.b    'weakened at this point and just when you think you''ve made it away you feel a ',$D,$A   
            dc.b    'hook pierce your torso from behind. As you ran away you made yourself a linear ',$D,$A   
            dc.b    'target, easy target for a long distance lunge attack. ',$D,$A,$D,$A   
            dc.b    'You look down at your chest and the last thing you see is the hook being removed ',$D,$A   
            dc.b    'from your chest. You fall to the ground as blood gushes from the wound.',0

evenMsg     dc.b    'The both of you stand to face each other now. Tensions rise as you both hold ',$D,$A   
            dc.b    'your ground waiting for the other to make one final mistake.',$D,$A ,$D,$A  
            dc.b    '1.[Frustrated now, I summon all my remaining energy and charge forward!]',$D,$A,$D,$A   
            dc.b    '2.[Not willing to make another mistake I stand my ground readying a counter!]',0

rushMsg     dc.b    'You rush forward, filled with fury now! This has already taken far too long ',$D,$A   
            dc.b    'and you''re getting impatient. However the Hopper sees this, and while you ',$D,$A   
            dc.b    'charge forward in a blind rage it has calculated the perfect counter attack. ',$D,$A   
            dc.b    'Just when you think you are about to connect the final blow the Hopper springs ',$D,$A   
            dc.b    'up and over you, with energy you did not think it had left. You look on in ',$D,$A   
            dc.b    'horror as the Geth trails above you, its hooks reaching out towards your head. ',$D,$A,$D,$A   
            dc.b    'Before you have time to react each hook finds footing in each of your eyes, ',$D,$A   
            dc.b    'one after another. With the forward momentum you feel, with great agony, your ',$D,$A   
            dc.b    'head being pulled apart now and you fly along with the rest of the leap. By ',$D,$A   
            dc.b    'the time you land you have lost all vision, and with that the will to go on. ',$D,$A   
            dc.b    'You lay there, in a pool of growing blood, and waste away.',0

holdMsg     dc.b    'With patience you hold, and survey the situation. The Hopper is looking ',$D,$A   
            dc.b    'rattled now, he looks like he is getting anxious to do something. You think ',$D,$A   
            dc.b    'about taking out your gun now but you know it will just lunge at you before ',$D,$A   
            dc.b    'you get the chance to shoot. You hold.. ',$D,$A,$D,$A
            dc.b    'Then, suddenly the Geth starts to spring back into its legs and launches itself ',$D,$A      
            dc.b    'across the room in an attempt to cut you down where you stand. However you ',$D,$A   
            dc.b    'have a moment to see this brash behaviour and you ready your combat knife.',$D,$A ,$D,$A   
            dc.b    'You choose the perfect moment to break into a forward run, then you drop to a ',$D,$A   
            dc.b    'slide and just as you pass beneath this wretched creature you push your knife ',$D,$A   
            dc.b    'up, with great force. The blade penetrates the Geth and as you pass by each ',$D,$A   
            dc.b    'other the momentum does the rest of the work from there. You feel the knife ',$D,$A   
            dc.b    'rip along, gutting the Geth. As you slow to a halt you then pick yourself up  ',$D,$A   
            dc.b    'and look around. There, on the other side of the room lay the Hopper,',$D,$A   
            dc.b    'gutted like a fish.',0 


twoCoverMsg dc.b    'Sarah and Jake together: "Copy!"',$D,$A,$D,$A
            dc.b    'You make a dive for the building. As you stand up, you see Sarah and Jake pin ',$D,$A   
            dc.b    'themselves against the metal barricade.',0
  


wSarahMsg   dc.b    'Sarah and Jake together: "Copy!"',$D,$A,$D,$A
            dc.b    'Sarah sprints to your side as you both dive into the building. As you stand ',$D,$A   
            dc.b    'up, you see Jake pin himself up against the metal barricade.',$D,$A ,$D,$A   
            dc.b    'A Geth Hopper launches itself through the door in an attempt to hook onto your ',$D,$A   
            dc.b    'face. Sarah however, tackles it to the floor, and wraps her hands around its ',$D,$A 
            dc.b    'torso.',$D,$A ,$D,$A 
            dc.b    'Sarah: "I can handle this one Commander! You go and secure the back of the ',$D,$A 
            dc.b    'building!"',$D,$A ,$D,$A 
            dc.b    'The Hopper pierces her through the cheek with one of its hooks as Sarah ',$D,$A 
            dc.b    'tightens her grip. The Hopper flings its arm around forcing her to release her ',$D,$A 
            dc.b    'grip and move along with the hook. The Hopper then stands up and stomps onto ',$D,$A 
            dc.b    'Sarah''s jaw. ',$D,$A ,$D,$A 
            dc.b    'You think to yourself how lucky you were to have someone with you who has your ',$D,$A 
            dc.b    'back, as you imagine how this might have gone down had you been alone. But not ',$D,$A 
            dc.b    'wanting Sarah''s distraction efforts to be in vain, you press forward!',0
            
ripJakeMsg  dc.b    'You hear the deafening sound of the turret above you. You look through a ',$D,$A 
            dc.b    'window just in time to see lasers riddle the metal barricade, shattering it to ',$D,$A 
            dc.b    'pieces. One of the lasers flies through Jake''s head, and he flies backwards to ',$D,$A 
            dc.b    'the ground, streaking blood across it as he slides.',0  
 
            
    
wJakeMsg    dc.b    'Sarah and Jake together: "Copy!"',$D,$A,$D,$A
            dc.b    'Jake sprints to your side as you both dive into the building. As you stand up, ',$D,$A   
            dc.b    'you see Sarah pin herself up against the metal barricade.',$D,$A,$D,$A   
            dc.b    'A Geth Hopper launches itself through the door in an attempt to hook onto your ',$D,$A   
            dc.b    'face. Jake however, tackles it to the floor, and wraps his hands around its ',$D,$A   
            dc.b    'torso.',$D,$A ,$D,$A   
            dc.b    'Jake: "I can handle this one Commander! You go and secure the back of the ',$D,$A   
            dc.b    'building!"',$D,$A,$D,$A   
            dc.b    'The Hopper pierces him through the cheek with one of its hooks as Jake ',$D,$A   
            dc.b    'tightens his grip. The Hopper flings its arm around forcing Jake to release ',$D,$A   
            dc.b    'his grip and move along with the hook. The Hopper then stands up and stomps ',$D,$A   
            dc.b    'onto Jakes jaw. ',$D,$A,$D,$A     
            dc.b    'You think to yourself how lucky you were to have someone with you who has your ',$D,$A   
            dc.b    'back, as you imagine how this might have gone down had you been alone. But not ',$D,$A   
            dc.b    'wanting Jake''s distraction efforts to be in vain, you press forward!',0
  
ripSarahMsg dc.b    'You hear the deafening sound of the turret above you. You look through a ',$D,$A   
            dc.b    'window just in time to see lasers riddle the metal barricade, shattering it to ',$D,$A   
            dc.b    'pieces. One of the lasers flies through Sarah''s head, and she flies backwards ',$D,$A   
            dc.b    'to the ground, streaking blood across it as she slides.',0
 
twoDeathMsg dc.b    'You hear the deafening sound of the turret above you. You look through a ',$D,$A   
            dc.b    'window just in time to see lasers riddle the metal barricade, shattering it to ',$D,$A   
            dc.b    'pieces. One of the lasers flies through Jake''s head, and he flies backwards ',$D,$A  
            dc.b    'to the ground, streaking blood across it as he slides. Sarah dives out of the ',$D,$A   
            dc.b    'way, and aims her sniper at the turret. The turret turns to you, and charges ',$D,$A   
            dc.b    'up. ',$D,$A ,$D,$A 
            dc.b    'Before it can fire Sarah''s sniper fires a laser through the gunner''s head. ',$D,$A     
            dc.b    'However, she has now put herself in the light of sight of the Geth Rocket ',$D,$A   
            dc.b    'Trooper nearby. You see now a missile heading straight for Sarah just then. It ',$D,$A   
            dc.b    'collides with her, melting the flesh from her bone. ',0
 
endOfBattle dc.b    'With no time to dwell on the chaos of the battle, you rush through to the back ',$D,$A   
            dc.b    'of the building and kick through the door to the last room.',$D,$A,$D,$A    
            dc.b    'Here you find Legion, the Geth VI, sitting in a chair, unguarded.',0 
            
legionMsg   dc.b    '//Placeholder story until I hand up for extension this friday.',$D,$A   
            dc.b    '//Legion tries to convince you to let him and his people live.',$D,$A   
            dc.b    '//The Geth are all but extinct thanks to being led astray by Saran and',$D,$A   
            dc.b    '//Soveirgn. And you are not helping by hunting down all the retreating geth.',$D,$A   
            dc.b    '//let him live and get stabbed in back / or get saved by teammate',$D,$A   
            dc.b    '//shoot him mid sentece',$D,$A   
            dc.b    '//Search the office for 350 credits',$D,$A   
            dc.b    '//Blow up base killing all geth inside',$D,$A   
            dc.b    '//Back to Normandy',$D,$A   
            dc.b    '//Hire some more crew with new credits',$D,$A   
            dc.b    '//Another distress beacon comes in = more geth to hunt down',$D,$A   
            dc.b    '//as about to setoff for this, Hulking ship comes along and destroys SSV',$D,$A   
            dc.b    '// = ME2 opening. you drift off into space... Thanks for playing',0 


  
     
            dc.b    '',$D,$A   
    END    START        ; last line of source
    




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
