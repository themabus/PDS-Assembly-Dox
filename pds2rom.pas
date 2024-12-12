//compile with Free Pascal: fpc pds2rom.pas
{$MODE DELPHI}
program pds2rom;
uses
  SysUtils,
  Classes;

var
  fin	: TFileStream;
  fmem  : TFileStream;
  fout	: TFileStream;
  Nfin	: String;
  Nfmem : String;
  Sfin	: UInt32 = 0;//input size
  Dfin  : array of UInt8;//input data

  BankTMP  : array of UInt8;//bank template
  BankData : array of array of UInt8;
  BankName : array of String;

  BytesRead	: UInt32 = 0;
  BytesWritten	: UInt32 = 0;
  FileOffset	: Uint32 = 0;//current offset in input file
  MemOffset	: UInt32 = 0;//specified offset of memory dump
  BlockAddr	: UInt32 = 0;
  BlockSize	: UInt32 = 0;
  BankNr	: UInt32 = 0;
  ExecNr	: UInt32 = 0;//execution number - starts new bank and shows as 1st char in file name
  Records	: UInt32 = 1;//records in output array
  i		: UInt32 = 0;
  Copy		: boolean = false;//processing $b4 data block
  Initialized	: boolean = false;//$b7 sets 1st bank or next one?
  VerSet	: boolean = false;//PDS version determined?
  Ver2		: boolean = false;//b7 is 8 bits for PDS but 16 bits for PDS2

const
  BankSize	= $10000;//65536

procedure Help;
begin
    writeln('pds2rom (c) themabus 2023');
    writeln('-------------------------');
    writeln('pds2rom pdsoutput [memorydump [offset]]');
    halt(1);
end;

procedure BankPrep;
begin
    setLength(BankName, Records);
    setLength(BankData, Records, BankSize);//output array
    Move(BankTMP[0], BankData[Records-1, 0], BankSize);
end;

BEGIN
  try//finally
  try//except
//////////////////////////////////////////////////////////////////////////////// commandline
    if (ParamCount < 1) or (ParamCount > 3) then Help;
    if Paramstr(1)<>'' then Nfin:=Paramstr(1) else Help;
    if ParamCount = 3 then MemOffset := StrToInt(Paramstr(3));
    if MemOffset >= BankSize then MemOffset := 0;
//////////////////////////////////////////////////////////////////////////////// overlay stuff
    setLength(BankTMP, BankSize);
    FillDWord(BankTMP[0], BankSize div 4, $0);

    //set bank template from memory dump
    if ParamCount >= 2 then begin
        Nfmem := Paramstr(2);
        fmem := TFileStream.Create(Nfmem, fmOpenRead);
        Sfin := fmem.Size;
        writeln('Mem File:    ' + Nfmem);
        writeln('Mem Offset:  ' + hexstr(MemOffset, 4) + ' (' +inttostr(MemOffset) + ')');
        writeln;

        setLength(Dfin, Sfin);
        BytesRead := fmem.Read(Dfin[0], Sfin);

        while (BytesRead > 0) and (MemOffset < BankSize) do begin
            BankTMP[MemOffset] := Dfin[FileOffset];
            MemOffset += 1;
            FileOffset += 1;
            BytesRead -= 1;
        end;
        Sfin := 0;
        FileOffset := 0;
    end;
//////////////////////////////////////////////////////////////////////////////// main
    fin := TFileStream.Create(Nfin, fmOpenRead);
    Sfin := fin.Size;
    if Sfin < 1 then Help;

    setLength(Dfin, Sfin);
    BytesRead := fin.Read(Dfin[0], Sfin);

    writeln('File Size:   ' + hexstr(BytesRead, 6) + ' (' +inttostr(BytesRead) + ')');
    writeln;

    BankPrep;
    BankName[Records-1] := IntToStr(ExecNr)+'bank'+IntToStr(BankNr)+'.bin';//default name for when bank is not specified '0bank0'

    writeln('File Offset: ' + hexstr(FileOffset, 6) + ' (' +inttostr(FileOffset) + ')');

    repeat

        if (Copy = false) then begin

            Case Dfin[FileOffset] of

                $b3 : begin//PADDING BYTE
                    writeln('Padding: ' + hexstr(1, 4) + ' (' +inttostr(1) + ')');
                    FileOffset += 1;
                end;

                $b7 : begin//SWITCH BANK
                    FileOffset += 1;
                    if (VerSet = false) then begin
                        if (FileOffset+1 < BytesRead) 
                          and ((Dfin[FileOffset+1] <> $b3) and (Dfin[FileOffset+1] <> $b4) and (Dfin[FileOffset+1] <> $b5) and (Dfin[FileOffset+1] <> $b7)) 
                          then Ver2 := true;
                        VerSet := true;
                    end;
                    //PDS2
                    if Ver2 then begin
                        BankNr := Dfin[FileOffset];
                        FileOffset += 1;
                        BankNr += Dfin[FileOffset] << 8;
                    end
                    //PDS
                    else BankNr := Dfin[FileOffset];
                    writeln('Bank:    ' + hexstr(BankNr, 4) + ' (' +inttostr(BankNr) + ')');
                    FileOffset += 1;
                    if (FileOffset = BytesRead) then break;//last command - bail
                    //prepare next bank
                    if (Initialized) then begin
                        Records += 1;
                        BankPrep;
                    end;
                    BankName[Records-1] := IntToStr(ExecNr)+'bank'+IntToStr(BankNr)+'.bin';
                end;

                $b5 : begin//EXECUTE
                    FileOffset += 1;
                    BlockAddr := Dfin[FileOffset] << 8;
                    FileOffset += 1;
                    BlockAddr := BlockAddr + Dfin[FileOffset];
                    FileOffset += 1;
                    ExecNr += 1;
                    writeln('Execute: ' + hexstr(BlockAddr, 4) + ' (' +inttostr(BlockAddr) + ')');
                    writeln;
                    if (FileOffset = BytesRead) then break;//last command - bail
                    //prepare clean bank
                    if (Initialized) then begin
                        Records += 1;
                        BankPrep;
                    end;
                    BankName[Records-1] := IntToStr(ExecNr)+'bank'+IntToStr(BankNr)+'.bin';
                end;

                $b4 : begin//SEND
                    FileOffset += 1;
                    BlockAddr := Dfin[FileOffset] << 8;
                    FileOffset += 1;
                    BlockAddr := BlockAddr + Dfin[FileOffset];
                    FileOffset += 1;
                    BlockSize := Dfin[FileOffset] << 8;
                    FileOffset += 1;
                    BlockSize := BlockSize + Dfin[FileOffset];
                    FileOffset += 1;
                    Copy := true;
                    Initialized := true;
                    writeln('Address: ' + hexstr(BlockAddr, 4) + ' (' + inttostr(BlockAddr) + ')');
                    writeln('Size:    ' + hexstr(BlockSize, 4) + ' (' + inttostr(BlockSize) + ')');
                    writeln;
                end;

                else begin
                    writeln('error:   couldn''t find control!');
                    halt(3);
                end;

            end;
        end;

        if (Copy) then begin
            BankData[Records-1, BlockAddr] := Dfin[FileOffset];
            BlockSize -= 1;
            BlockAddr += 1;
            FileOffset += 1;
            if (BlockSize <= 0) then begin
                Copy := false;
                if (FileOffset < BytesRead) then writeln('File Offset: ' + hexstr(FileOffset, 6) + ' (' +inttostr(FileOffset) + ')');
            end;
        end;

    until FileOffset >= BytesRead;

    if (BlockSize > 0) then begin
        writeln('error:   out of data!' + ' (' +inttostr(BlockSize) + ')');
        halt(2);
    end;

    while (i < Records) do begin
//        writeln(BankName[i]);
        fout:=TFileStream.Create(BankName[i], fmCreate);
        BytesWritten:=fout.Write(BankData[i, 0], BankSize);
        i += 1;
    end
////////////////////////////////////////////////////////////////////////////////
  except
    on E: Exception do Help;
  end;
  finally
    fin.free;
    fout.free;
    fmem.free;
  end;
END.