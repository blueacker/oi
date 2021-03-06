{$R-,Q-,S-}
Const
    InFile     = 'cashier.in';
    OutFile    = 'cashier.out';
    Limit      = 110000;
    nilT       = 0;

Type
    Tnode      = record
                     key , sum ,
                     lc , rc , father        : longint;
                 end;
    Ttree      = object
                     rootT , tot             : longint;
                     data                    : array[0..Limit] of Tnode;
                     procedure init;
                     procedure Maintain(p : longint);
                     procedure Left_Rotate(p : longint);
                     procedure Right_Rotate(p : longint);
                     procedure Rotate(p : longint);
                     procedure Splay(p : longint);
                     procedure Insert(key : longint);
                     function Find(key : longint) : longint;
                     function Find_Index(sum : longint) : longint;
                     procedure Delete_Root_Lc;
                 end;

Var
    tree       : Ttree;
    totLeft ,
    init_Bound ,
    N , Bound  : longint;

procedure Ttree.init;
begin
    rootT := nilT; tot := 0;
    data[nilT].lc := 0; data[nilT].rc := 0; data[nilT].father := 0;
    data[nilT].sum := 0; data[nilT].key := 0;
end;

procedure Ttree.maintain(p : longint);
begin
    data[nilT].sum := 0;
    data[p].sum := data[data[p].lc].sum + data[data[p].rc].sum + 1;
end;

procedure Ttree.Left_Rotate(p : longint);
var
    x , y      : longint;
begin
    x := data[p].father; y := data[p].lc;
    data[p].lc := x; data[x].rc := y;
    if data[x].father = nilT
      then rootT := p
      else if data[data[x].father].lc = x
             then data[data[x].father].lc := p
             else data[data[x].father].rc := p;
    data[p].father := data[x].father;
    data[x].father := p;
    data[y].father := x;
    maintain(x); maintain(p);
end;

procedure Ttree.Right_Rotate(p : longint);
var
    x , y      : longint;
begin
    x := data[p].father; y := data[p].rc;
    data[p].rc := x; data[x].lc := y;
    if data[x].father = nilT
      then rootT := p
      else if data[data[x].father].lc = x
             then data[data[x].father].lc := p
             else data[data[x].father].rc := p;
    data[p].father := data[x].father;
    data[x].father := p;
    data[y].father := x;
    maintain(x); maintain(p);
end;

procedure Ttree.Rotate(p : longint);
begin
    if data[data[p].father].lc = p
      then Right_Rotate(p)
      else Left_Rotate(p);
end;

procedure Ttree.Splay(p : longint);
var
    x          : longint;
begin
    while p <> rootT do
      if data[p].father = rootT
        then Rotate(p)
        else begin
                 x := data[p].father;
                 if (data[data[x].father].lc = x) = (data[x].lc = p)
                   then begin Rotate(x); Rotate(p); end
                   else begin Rotate(p); Rotate(p); end;
             end;
end;

procedure Ttree.Insert(key : longint);
var
    p , fp     : longint;
begin
    inc(tot); data[tot].key := key; data[tot].lc := 0; data[tot].rc := 0;
    data[tot].father := 0; data[tot].sum := 1;
    if rootT = nilT
      then rootT := tot
      else begin
               p := rootT; fp := 0;
               while p <> nilT do
                 begin
                     inc(data[p].sum); fp := p;
                     if data[p].key < key
                       then p := data[p].rc
                       else p := data[p].lc;
                 end;
               if data[fp].key < key
                 then data[fp].rc := tot
                 else data[fp].lc := tot;
               data[tot].father := fp;
               Splay(tot);
           end;
end;

function Ttree.Find(key : longint) : longint;
var
    p , fp     : longint;
begin
    Find := -1;
    if rootT = nilT then exit;
    p := rootT; fp := 0;
    while p <> nilT do
      begin
          fp := p;
          if data[p].key < key
            then begin Find := p; p := data[p].rc; end
            else p := data[p].lc;
      end;
    Splay(fp);
end;

function Ttree.Find_Index(sum : longint) : longint;
var
    p          : longint;
begin
    Find_Index := -1;
    if sum > data[rootT].sum then exit;
    sum := data[rootT].sum - sum + 1;
    p := rootT;
    while true do
      if sum <= data[data[p].lc].sum
        then p := data[p].lc
        else if sum = data[data[p].lc].sum + 1
               then begin
                        Splay(p); Find_Index := p;
                        exit;
                    end
               else begin
                        dec(sum , data[data[p].lc].sum + 1);
                        p := data[p].rc;
                    end;
end;

procedure Ttree.Delete_Root_Lc;
begin
    if rootT = nilT then exit;
    if data[rootT].Rc = nilT then begin rootT := nilT; exit; end;
    rootT := data[rootT].Rc; data[rootT].father := nilT;
end;

procedure main;
var
    i , K , p  : longint;
    ch         : char;
begin
    assign(INPUT , InFile); ReSet(INPUT);
    assign(OUTPUT , OutFile); ReWrite(OUTPUT);
      readln(N , Bound);
      init_Bound := Bound;
      tree.init; totLeft := 0;
      for i := 1 to N do
        begin
            readln(ch , K);
            case ch of
              'I'             : begin
                                    if K < init_Bound
                                      then inc(totLeft)
                                      else tree.Insert(K - init_Bound + Bound);
                                end;
              'A'             : dec(Bound , K);
              'S'             : begin
                                    inc(Bound , K);
                                    p := tree.Find(Bound);
                                    if p <> -1 then
                                      begin
                                          tree.Splay(p);
                                          inc(totLeft , tree.data[tree.data[p].lc].sum + 1);
                                          tree.Delete_Root_Lc;
                                      end;
                                end;
              'F'             : begin
                                    p := tree.Find_Index(K);
                                    if p = -1
                                      then writeln(-1)
                                      else writeln(tree.data[p].key - Bound + init_Bound);
                                end;
            end;
        end;
      writeln(totLeft);
    Close(OUTPUT);
    Close(INPUT);
end;

Begin
    main;
End.
