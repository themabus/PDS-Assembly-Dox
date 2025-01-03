# PDS-Assembly-Dox
This is a quick assembly guide for the 80s/90s source codes written using Programmers Development System (PDS).
### CAUTION!
It appears that on some occasions an error message about insufficient __FILES__ in __CONFIG.SYS__ may appear, 
when saving the files from PDS editor, resulting in the erasure of the content of those files.
So please don't even think about directly feeding it your original sources from unprotected floppies or something silly like that.
<br>
### Some examples, from easy to more finicky:
CPC __Dizzy 3__ (https://github.com/Wireframe-Magazine/Wireframe19)
- compile for __amstrad__ with __PDSZ80f.EXE__ to get __AA__ or with __PDSZ80c.EXE__ on __DOSBox-X__<br>
to get serial output __ser2.bin__
- unpack it to __0bank0.bin__ with __pds2rom.exe aa__
- use __CaPriCe Forever__
- set breakpoint: __&0dfb__
- run __call &0dfb__ to activate BP
- memory editor/dump/import bin
- unpause debugger and it should execute from set PC
<br>

CPC __Lop Ears__ (https://spectrumcomputing.co.uk/forums/viewtopic.php?t=1932)
- compile with __PDSZ80f.EXE__ to get __AA__ or with __PDSZ80c.EXE__ on __DOSBox-X__ to get serial output __ser2.bin__
- unpack it to __0bank0.bin__ with __pds2rom.exe aa__
- trim it with __sfk partcopy 0bank0.bin -yes -allfrom 0x300 out.bin__
- use __CaPriCe Forever__
- set breakpoint: __&2328__
- run __call &2328__ to activate BP
- memory editor/dump/import bin
- set __From__ to __&300__ before importing
- unpause debugger and it should execute from set PC
<br>

ZX __Street Cred Football__ (https://spectrumcomputing.co.uk/forums/viewtopic.php?t=1932)
- compile with __PDSZ80f.EXE__ to get __AA__ or with __PDSZ80c.EXE__ on __DOSBox-X__ to get serial output __ser2.bin__
- unpack it to __0bank0.bin__ with __pds2rom.exe aa__
- trim it with __sfk partcopy 0bank0.bin -yes -allfrom 0x4000 out.bin__
- use __ZXSpin__
- Tools/Debugger set breakpoint: __#9472__ (as __38002__ is specified in X0 comments)
- run __randomize usr 38002__ to activate BP (T Ctrl+Shift L 38002)
- File/Load Binary
- set __Start__ to __#4000__ before importing
- unpause debugger and it should execute from set PC
<br>

C64 __Altered Beast Intro__ (https://github.com/milkeybabes?tab=repositories)
- compile x?.tap files with __PDS6502f.EXE__ to get __AA__ or with __PDS6502c.EXE__ on __DOSBox-X__<br>
to get serial output __ser2.bin__
- unpack it to __0bank0.bin__ with __pds2rom.exe aa__
- prepend rom with 2 bytes and remove last 2: <- C64 emulator quirk<br>
__sfk partcopy 0bank0.bin -yes -fromto 0 2 addr.bin__<br>
__copy /b addr.bin +0bank0.bin out.bin__<br>
__sfk partcopy out.bin -yes -fromto 0 0x10000 intro.prg__<br>
(so if those 2 bytes happen to be meaningful, fill them from debugger later on)<br>
- use __Z64K__
- Applications/Machine Monitor<br>
__l "intro.prg" 0__<br>
__g 9837__<br>
- close Monitor and it should run
<br>

C64 __Alien 3__ (https://github.com/milkeybabes?tab=repositories)
- compile __EFFECTS.PDS__ with __PDS6502f.EXE__ to get __AA__ or with __PDS6502c.EXE__ on __DOSBox-X__<br>
to get serial output __ser2.bin__
- process it as Intro above (with 2 extra zero bytes) and you should have __effects.prg__
- open 0-7.PDS in PDS and set __TAPE_LOADER__ to 0 and uncomment __START_CODE__ at the end of 7th window
- try to compile and get an error about a missing gfx file
- go to __SPRITES__ directory and copy __JUMP.SPR__ to __THROW.SPR__, __TUMBLE.SPR__ and __TURN.SPR__
- copy __JUMP.REV__ to __THROW.REV__, __TUMBLE.REV__ and __TURN.REV__
- now compile it and process output as __Altered Beast Intro__ or __EFFECTS.PDS__ into __alien3.prg__
- launch __Z64K__ and fire up Monitor<br>
__l "alien3.prg" 0__<br>
__g f300__<br>
- notice assembler instructions dont make sense<br>
this is because this memory space is mapped to Kernal so we first have to map this region to RAM<br>
how upsetting, lets cheer ourselves up with some wicked beats<br>
__l "effects.prg" 0__<br>
__g 1791__<br>
- close Monitor to launch effects sampler
- after you've cheered up proper, open Monitor again and __g f300__; notice it has removed Kernal for us
- __l "alien3.prg" 0__
- execute __g f300__ again to refresh the instruction window and you should see the familiar loader routine
- close Monitor and the game should run now
<br>

SMS __The Fantastic Adventures of Dizzy__ (https://spectrumcomputing.co.uk/forums/viewtopic.php?t=1932)<br>
this game assembles with PDS/2 for Z80 __P2Z80.EXE__ which was kindly provided in the same archive<br>
as the source code<br>
- replace all instances of __C:\SEGA8BIT\BIGDIZZY\\__ in __FANTSEGA.PRJ__ with nothing, to get relative paths
- search for __incbin__ in source files and, like above, replace all __C:\SEGA8BIT\BIGDIZZY\\__ paths with nothing<br>
this should affect 2 .dat files and 15 .inc files<br>
- in __PAGE2.ROU__ change __D:\UTILS\FLEX\UNFLEX.Z80__ -> __UNFLEX.Z80__
- copy in __UNFLEX.Z80__ from the archive
- comment out __PATH__ string at the top of __MACROS.ROU__ and chabge __SEND COMPUTER1__ to __SEND SERIAL__
- the game should now compile, producing binary output from serial port in your __DOSBox-X__ directory<br>
- close __DOSBox__ and move this file someplace else; it should be __259842__ bytes long<br>
- now lets create an 64k FF filled file:<br>
__sfk make-zero-file bank 0x10000__<br>
__sfk rep bank -yes -binary /00000000/ffffffff/__ <br>
- unpack data:<br>
__pds2rom.exe ser1.bin bank >log__ <br>
- trim garbage:<br>
__sfk partcopy 0bank64.bin -yes -fromto 0x0000 0x4000 64.bin__<br>
__sfk partcopy 0bank65.bin -yes -fromto 0x4000 0x8000 65.bin__<br>
__sfk partcopy 0bank66.bin -yes -fromto 0x8000 0xc000 66.bin__<br>
...<br>
__sfk partcopy 0bank79.bin -yes -fromto 0x8000 0xc000 79.bin__<br>
- join all banks:<br>
__copy /b 64.bin +65.bin +66.bin +67.bin +68.bin +69.bin +70.bin +71.bin +72.bin +73.bin +74.bin +75.bin +76.bin +77.bin +78.bin +79.bin dizzy.sms__<br>
- and finally we shoul add a header:<br>
__sfk -yes setbytes dizzy.sms 0x7ff0 0x544d5220534547410000000000000040__<br>
- this ROM should now work in SMS emulators, such as __Emulicious__ or __MEKA__
<br>

NES __Hero Quest__ (http://shrigley.com/source_code_archive/)
- compile with __PDS6502f.EXE__ to get __A?__ or with __PDS6502c.EXE__ on __DOSBox-X__ to get serial output __ser2.bin__<br>
1) _if you saved data from serial port:_ <br>
- unpack it to __0bank?.bin__ with __pds2rom.exe ser2.bin__
- trim files with sfk:<br>
__sfk partcopy 0bank0.bin -yes -fromto 0x8000 0xc000 out0.bin__<br>
__sfk partcopy 0bank1.bin -yes -fromto 0x8000 0xc000 out1.bin__<br>
...<br>
__sfk partcopy 0bank6.bin -yes -allfrom 0x8000 out6.bin__<br>
- join all files<br>
__copy /b out0.bin +out1.bin +out2.bin +out3.bin +out4.bin +out5.bin +out6.bin tmp.bin__<br>
2) _if you saved to file:_ <br>
- unpack and process this data like so<br>
__pds2rom.exe aa__<br>
__move 0bank0.bin tmp0.bin__<br>
__sfk partcopy tmp0.bin -yes -fromto 0x8000 0xc000 out0.bin__<br>
__pds2rom.exe ab__<br>
__move 0bank0.bin tmp1.bin__<br>
__sfk partcopy tmp1.bin -yes -fromto 0x8000 0xc000 out1.bin__<br>
...<br>
__pds2rom.exe ah__<br>
__move 0bank0.bin tmp7.bin__<br>
__sfk partcopy tmp7.bin -yes -allfrom 0xc000 out7.bin__<br>
- join all files<br>
__copy /b out0.bin +out1.bin +out2.bin +out3.bin +out4.bin +out5.bin +out6.bin +out7.bin tmp.bin__<br>
3) _continue here in both cases_ <br>
- prepend __tmp.bin__ with a 16 byte header using an HEX editor or with __sfk setbytes__<br>
4E 45 53 1A 08 00 20 00-00 00 00 00 00 00 00 00<br>
__sfk -yes make-random-file header 16__<br>
__sfk -yes setbytes header 0 0x4e45531a080020000000000000000000__<br>
__copy /b header +tmp.bin hq.nes__<br>
- now you can open this ROM in any NES emulator
<br>

NES __NES Tank Game__ (http://www.iancgbell.clara.net/nestank/)<br>
this game was produced on 6502 PDS/2 and since it is currently MIA we'll have to sqeeze it into an PDS project<br>
- rename following files:<br>
__move BZLINE.PDS 1.PDS__<br>
__move BZLOGS.PDS 2.PDS__<br>
__move BZMATH.PDS 3.PDS__<br>
__move BZDVLP.PDS 4.PDS__<br>
__move BZNMIR.PDS 5.PDS__<br>
__move BZNTRA.PDS 6.PDS__<br>
__move BZLAST.PDS 7.PDS__<br>
__copy BZDFNS.PDS +BZFRST.PDS +BZFRGR.PDS 0.PDS__<br>
- now let's create a FF pattern filled 64kb overlay file<br>
__sfk make-zero-file bank 0x10000__<br>
__sfk rep bank -yes -binary /00000000/ffffffff/__<br>
- in __0.PDS__ set __ROMCODE__ to __1__, __TESTSTUFF__ to __0__ and replace __SEND ROMFILE,TANK.ROM,128__ with<br>
__SEND COMPUTER1__
- in __0.PDS__, where __BZFRST.PDS__ would end (after __noobj equ (*-OBJDEF)/16__) add<br>
&emsp;__include	BZMACR.PDS__<br>
- compile the game and then process two output files like so<br>
__pds2rom.exe aa bank__<br>
__move 0bank0.bin tmp0.bin__<br>
__sfk partcopy tmp0.bin -yes -fromto 0x8000 0x10000 out0.bin__<br>
__sfk partcopy tmp0.bin -yes -fromto 0 0x8000 out1.bin__<br>
__pds2rom.exe ab bank__<br>
__move 0bank0.bin tmp1.bin__<br>
__sfk -yes make-random-file header 16__<br>
__sfk -yes setbytes header 0 0x4e45531a080010000000000000000000__<br>
__copy /b header +out0.bin +out1.bin +tmp1.bin tank.nes__<br>
- you should now have a ROM image matching to the one Ian Bell shared on his website
<br>

NES __Elite__ (http://www.elitehomepage.org/archive/index.htm)<br>
UPDATE: on the 1st day of 2025 Hidden Place community shared NES PDS2 along with __The Lion King__ source code,<br>
so now assembling this game is as easy as correcting paths in __NELITE.PRJ, ELITEA1.PDS, NELITEJ.PDS, NELITEZ.PDS__ <br>
I'm keeping the old conversion guide below for the reference<br>
<br>
same as with the __NES Tank Game__ this is a PDS/2 project so we should take care to downconvert it to PDS<br>
PDS can load up to 8 files of a limited size; loops can not be used in include files; includes can not be nested<br>
- first move all .PDS files from both subdirectories to the outer one, where __NELITE.PRJ__ is
- go through all the .PDS files and correct __incbin__ file references to relative ones e.g.<br>
__CFAC6OBJ.DAT__ should be __NIEL1\CFAC6OBJ.DAT__<br>
__C:\PDS\JOEL1\NTSCTOK.dat__ -> __JOEL1\NTSCTOK.dat__<br>
__\PDS\JOEL1\WORDSD.DAT__ -> __JOEL1\WORDSD.DAT__<br>
they are in 8 files in total and all the references from each file are to one of subdirectories, i.e. paths dont mix<br>
- examine __NELITE.PRJ__ and note the file order, we will try to replicate it<br>
0) <br>
- rename __NELITE0.PDS__ to __0.PDS__: __move NELITE0.PDS 0.PDS__
- in __0.PDS__ delete 200something spaces at the end of line __228__ (__pic2bank EQU 4+STBANK__) & line __230__
- in __0.PDS__ change both __SEND ROMFILE__ lines to __SEND COMPUTER1__
- at the end of __0.PDS__ add the following includes<br>
&emsp;__include	ELITE1.PDS__<br>
&emsp;__include	NELITE2.PDS__<br>
&emsp;__include	ELITE3.PDS__<br>
&emsp;__include	ELITEG1.PDS__<br>
&emsp;__include	NELITEG2.PDS__<br>
1) <br>
- __move ELITEA1.PDS 1.PDS__<br>
2) <br>
- go to the line __2137__ in __NELITEA3.PDS__ and cut everything above it. save
- paste your clipboard in a new file and save it as __2.PDS__, so __fudcl2__ should be the last little block in it
- add the following includes at the end of __2.PDS__:<br>
&emsp;__include	NELITEA3.PDS__<br>
&emsp;__include	ELITEA4.PDS__<br>
&emsp;__include	NELITES.PDS__<br>
so we essentially separated __NELITEA3.PDS__ into two parts to reduce file size and bring loops out of include<br>
3) <br>
- go to the line __1929__ in __NELITES2.PDS__ and cut everything above it. save
- paste your clipboard in a new file and save it as __3.PDS__; it should conclude with a __slmess5I__ text block
- add the following includes at the end of it:<br>
&emsp;__include	NELITES2.PDS__<br>
&emsp;__include	ELITEB.PDS__<br>
&emsp;__include	ELITEC.PDS__<br>
&emsp;__include	ELITED.PDS__<br>
&emsp;__include	ELITEE.PDS__<br>
&emsp;__include	ELITEF.PDS__<br>
&emsp;__include	ELITEH.PDS__<br>
4)
- __move ELITEI.PDS 4.PDS__<br>
5)
the unfortunate thing with __NELITEJ.PDS__ is that it exceeds the size limit and has loops throughout it<br>
so we'll really have to carve this one up to pieces<br>
- create a new __5.PDS__ file and add in it<br>
&emsp;__include	NELITEJ1.PDS__<br>
- cut everything above the line __1188__ from __NELITEJ.PDS__ and paste it into a new __NELITEJ1.PDS__ file
- cut everything above the line __720__ from __NELITEJ.PDS__ and paste it into __5.PDS__ below include<br>
this block should start with __traL1__ and conclude with __LOOP__<br>
- at the end of __5.PDS__ add<br>
&emsp;__include	NELITEJ2.PDS__<br>
- cut everything starting (so going down this time) with the __sequence__ label on the line __1226__ from __NELITEJ.PDS__<br>
and paste it at the end of __5.PDS__<br>
- rename __NELITEJ.PDS__ to __NELITEJ2.PDS__; it should start with __GINF TXA__ and conclude with __RTS__ instruction
6)
- __move NELITEK.PDS 6.PDS__<br>
- add these 3 includes at the end of it:<br>
&emsp;__include	NELITEL1.PDS__<br>
&emsp;__include	ELITEL2.PDS__<br>
&emsp;__include	ELITEM.PDS__<br>
7)
- __move NELITEZ.PDS 7.PDS__<br><br>
if you'd try to compile now, PDS will complain about a syntax error in __NELITEL1.PDS__<br>
we'll have to modify some macros to compensate for the missing bank reference functionality<br>
of the older program version we're using<br>
- find and replace all 6 instances of __#|@1__ with __#@2__
- also in __NELITEL1.PDS__ replace __#|TT66__ with __#0__ and __#|LL145__ with __#1__
- now we should supply a 2nd parameter to every instance of 1 of 4 __SMARTJMP__ macros we just modified<br>
the first one is on the line __452__, add __,6__ at the end of it<br>
- the next one is on the line __463__, add __,6__ at the end of it
- add __,6__ to the end of line __465__ and __474__
- continue searching for __SMARTJMP__ and adding values __5,4,4,3,6,1,3,1,6,1,1,1,3,3,4,6,6,4,6,0,0,3__<br>
until youll come to a commented out __SENDPALLETE SMARTJMP SENDPALLETEtrue__ line; let's ignore this one
- continue down adding: __3,3,3,6,3,6,6,3,3,6,0,5,5__ until __GETPWRFACE SMARTJMP3 GETPWRFACEtrue__<br>
which should be ignored
- add seven more parameters __4,4,6,6,0,6,6__ and ignore commented out __NOISE SMARTJMP3 NOISEtrue__
- supply two more parameters __6,6__ for macros and ignore __BOXINPUT SMARTJMP2 BOXINPUTtrue__<br>
excluded with __IF__ directive
- continue adding from __GTNME__ __6,6,6,6,0,2,2,2,3,3,3,3,3,3,3,3,3,0,6,0,1,2,2,2,2,0,0,1,3,1,0__ up until __ENDTMODEsmart__<br>
take care to add the parameter before the comment on the line __631__<br>
- the game should now compile, producing 8 output files
- like with __NES Tank__, create a FF pattern filled 64kb overlay file<br>
__sfk make-zero-file bank 0x10000__<br>
__sfk rep bank -yes -binary /00000000/ffffffff/__<br>
- unpack all the binaries<br>
__pds2rom.exe aa bank__<br>
__move 0bank0.bin tmp0.bin__<br>
...<br>
__pds2rom.exe ah bank__<br>
__move 0bank0.bin tmp7.bin__<br>
- remove the garbage<br>
__sfk partcopy tmp0.bin -yes -fromto 0x8000 0xc000 out0.bin__<br>
__sfk partcopy tmp1.bin -yes -fromto 0x8000 0xc000 out1.bin__<br>
...<br>
__sfk partcopy tmp7.bin -yes -fromto 0xc000 0x10000 out7.bin__<br>
- don't forget the header<br>
__sfk -yes make-random-file header 16__
__sfk -yes setbytes header 0 0x4e45531a080012000000000000000000__
- and finally we join all the banks to produce a working ROM image<br>
__copy /b header +out6.bin +out1.bin +out2.bin +out3.bin +out0.bin +out4.bin +out5.bin +out7.bin elite.nes__
- you can pat yourself on the back now for hacking the original NES Elite source code to a working state
<br>

### Oh No! More PDS:
- __Buggy Boy__ (ZX)<br>
https://web.archive.org/web/20031209144200/http://maz.spork.dk/src/index.html
- __Wacky Races__ (C64)<br>
https://www.gamesthatwerent.com/gtw64/wacky-races-v1/
- __Jeroen Tel's music__ (SMS)<br>
https://www.smspower.org/forums/12696-JeroenTelSourceCode
- __Super Robin Hood__ (NES)<br>
https://github.com/Wireframe-Magazine/Wireframe-34
- __Chicken Run__ (GBC) with GB PDS<br>
https://archive.org/details/chicken-run-gbc-source-code-sep-7-2000
- __The Lion King__ (GB/NES) with GB & NES PDS<br>
https://hiddenpalace.org/Assets/The_Lion_King/Game_Boy_and_NES_source_code
- __x86 PDS for Konix Multi-system__<br>
http://www.konixmultisystem.co.uk/index.php?id=downloads<br>
https://www.youtube.com/watch?v=kicsmgNn-VQ
<br>

* PDS6502.EXE was kindly provided by CSDb community
* sfk is __Swiss File Knife__ http://stahlworks.com/dev/swiss-file-knife.html
* PDS has a built in __SEND MSDOS,file.ext__ command for output to file<br>
but it has a problem with multi bank output overwriting itself<br>
to amend this I provided modified __f__ exe versions<br>
it is better to not specify this MSDOS output with those hacked versions<br>
but just send to either COMPUTER1/2 or SERIAL and everything should go to file<br>
* older PDSZ80 projects appear to compile well with P2Z80<br>
* P2Z80 has additional __SEND ROMFILE,file.ext,128__ & __SEND ROM__ commands discussed here:<br>
https://worldofspectrum.org/forums/discussion/9588/
* if you have other versions of PDS, particularly PDS/2 for Z80 v2.72 / 6502 v2.73 (or above)<br>
please upload them on archive.org or github or some other public place<br>
