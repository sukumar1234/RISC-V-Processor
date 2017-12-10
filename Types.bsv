typedef 32 AddrSz;
typedef Bit#(AddrSz) Addr;

typedef 32 DataSz;
typedef Bit#(DataSz) Data;

typedef 32 InstSz;
typedef Bit#(InstSz) Instruction;

typedef Data MemResp;

typedef enum{Lb,Lh,Lw,Lbu,Lhu,Sb,Sh,Sw} MemOp deriving(Eq, Bits, FShow);
typedef struct{
    MemOp op;
    Addr  addr;
    Data  data;
} MemReq deriving(Eq, Bits, FShow);


typedef enum{Fetch,Execute} State deriving(Eq,Bits);

typedef struct{
Addr pc;
Addr ppc;
Instruction inst;
Bool epoch;
}Fetch2Execute deriving(Eq,Bits);
