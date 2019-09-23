# frozen_string_literal: true

module Mmrbc
  # from mrubyc/src/opcode.h
  OP_NOP	= 0x00	#!< Z    no operation
  OP_MOVE	= 0x01	#!< BB   R(a) = R(b)
  OP_LOADL	= 0x02	#!< BB   R(a) = Pool(b)
  OP_LOADI	= 0x03	#!< BB   R(a) = mrb_int(b)
  OP_LOADINEG	= 0x04	#!< BB   R(a) = mrb_int(-b)
  OP_LOADI__1	= 0x05	#!< B    R(a) = mrb_int(-1)
  OP_LOADI_0	= 0x06	#!< B    R(a) = mrb_int(0)
  OP_LOADI_1	= 0x07	#!< B    R(a) = mrb_int(1)
  OP_LOADI_2	= 0x08	#!< B    R(a) = mrb_int(2)
  OP_LOADI_3	= 0x09	#!< B    R(a) = mrb_int(3)
  OP_LOADI_4	= 0x0a	#!< B    R(a) = mrb_int(4)
  OP_LOADI_5	= 0x0b	#!< B    R(a) = mrb_int(5)
  OP_LOADI_6	= 0x0c	#!< B    R(a) = mrb_int(6)
  OP_LOADI_7	= 0x0d	#!< B    R(a) = mrb_int(7)
  OP_LOADSYM	= 0x0e	#!< BB   R(a) = Syms(b)
  OP_LOADNIL	= 0x0f	#!< B    R(a) = nil
  OP_LOADSELF	= 0x10	#!< B    R(a) = self
  OP_LOADT	= 0x11	#!< B    R(a) = true
  OP_LOADF	= 0x12	#!< B    R(a) = false
  OP_GETGV	= 0x13	#!< BB   R(a) = getglobal(Syms(b))
  OP_SETGV	= 0x14	#!< BB   setglobal(Syms(b), R(a))

  OP_GETIV	= 0x17	#!< BB   R(a) = ivget(Syms(b))
  OP_SETIV	= 0x18	#!< BB   ivset(Syms(b),R(a))

  OP_GETCONST	= 0x1b	#!< BB   R(a) = constget(Syms(b))
  OP_SETCONST	= 0x1c	#!< BB   constset(Syms(b),R(a))

  OP_GETUPVAR	= 0x1f	#!< BBB  R(a) = uvget(b,c)
  OP_SETUPVAR	= 0x20	#!< BBB  uvset(b,c,R(a))
  OP_JMP	= 0x21	#!< S    pc=a
  OP_JMPIF	= 0x22	#!< BS   if R(b) pc=a
  OP_JMPNOT	= 0x23	#!< BS   if !R(b) pc=a
  OP_JMPNIL	= 0x24	#!< BS   if R(b)==nil pc=a
  OP_ONERR	= 0x25	#!< S    rescue_push(a)

  OP_SENDV	= 0x2c	#!< BB   R(a) = call(R(a),Syms(b),*R(a+1))

  OP_SEND	= 0x2e	#!< BBB  R(a) = call(R(a),Syms(b),R(a+1),...,R(a+c))
  OP_SENDB	= 0x2f	#!< BBB  R(a) = call(R(a),Syms(Bx),R(a+1),...,R(a+c),&R(a+c+1))

  OP_SUPER	= 0x31	#!< BB   R(a) = super(R(a+1),... ,R(a+b+1))
  OP_ARGARY	= 0x32	#!< BS   R(a) = argument array (16=m5:r1:m5:d1:lv4)
  OP_ENTER	= 0x33	#!< W    arg setup according to flags (23=m5:o5:r1:m5:k5:d1:b1)

  OP_RETURN	= 0x37	#!< B    return R(a) (normal)
  OP_RETURN_BLK	= 0x38	#!< B    return R(a) (in-block return)
  OP_BREAK	= 0x39	#!< B    break R(a)
  OP_BLKPUSH	= 0x3a	#!< BS   R(a) = block (16=m5:r1:m5:d1:lv4)
  OP_ADD	= 0x3b	#!< B    R(a) = R(a)+R(a+1)
  OP_ADDI	= 0x3c	#!< BB   R(a) = R(a)+mrb_int(c)
  OP_SUB	= 0x3d	#!< B    R(a) = R(a)-R(a+1)
  OP_SUBI	= 0x3e	#!< BB   R(a) = R(a)-C
  OP_MUL	= 0x3f	#!< B    R(a) = R(a)*R(a+1)
  OP_DIV	= 0x40	#!< B    R(a) = R(a)/R(a+1)
  OP_EQ		= 0x41	#!< B    R(a) = R(a)==R(a+1)
  OP_LT		= 0x42	#!< B    R(a) = R(a)<R(a+1)
  OP_LE		= 0x43	#!< B    R(a) = R(a)<=R(a+1)
  OP_GT		= 0x44	#!< B    R(a) = R(a)>R(a+1)
  OP_GE		= 0x45	#!< B    R(a) = R(a)>=R(a+1)
  OP_ARRAY	= 0x46	#!< BB   R(a) = ary_new(R(a),R(a+1)..R(a+b))
  OP_ARRAY2	= 0x47	#!< BBB  R(a) = ary_new(R(b),R(b+1)..R(b+c))
  OP_ARYCAT	= 0x48	#!< B    ary_cat(R(a),R(a+1))

  OP_ARYDUP	= 0x4a	#!< B    R(a) = ary_dup(R(a))
  OP_AREF	= 0x4b	#!< BBB  R(a) = R(b)[c]

  OP_APOST	= 0x4d	#!< BBB  *R(a),R(a+1)..R(a+c) = R(a)[b..]
  OP_INTERN	= 0x4e	#!< B    R(a) = intern(R(a))
  OP_STRING	= 0x4f	#!< BB   R(a) = str_dup(Lit(b))
  OP_STRCAT	= 0x50	#!< B    str_cat(R(a),R(a+1))
  OP_HASH	= 0x51	#!< BB   R(a) = hash_new(R(a),R(a+1)..R(a+b))

  OP_BLOCK	= 0x55	#!< BB   R(a) = lambda(SEQ[b],L_BLOCK)
  OP_METHOD	= 0x56	#!< BB   R(a) = lambda(SEQ[b],L_METHOD)
  OP_RANGE_INC	= 0x57	#!< B    R(a) = range_new(R(a),R(a+1),FALSE)
  OP_RANGE_EXC	= 0x58	#!< B    R(a) = range_new(R(a),R(a+1),TRUE)

  OP_CLASS	= 0x5a	#!< BB   R(a) = newclass(R(a),Syms(b),R(a+1))

  OP_EXEC	= 0x5c	#!< BB   R(a) = blockexec(R(a),SEQ[b])
  OP_DEF	= 0x5d	#!< BB   R(a).newmethod(Syms(b),R(a+1))
  OP_ALIAS	= 0x5e	#!< BB   alias_method(target_class,Syms(a),Syms(b))

  OP_SCLASS	= 0x60	#!< B    R(a) = R(a).singleton_class
  OP_TCLASS	= 0x61	#!< B    R(a) = target_class

  OP_EXT1	= 0x64	#!< Z    make 1st operand 16bit
  OP_EXT2	= 0x65	#!< Z    make 2nd operand 16bit
  OP_EXT3	= 0x66	#!< Z    make 1st and 2nd operands 16bit
  OP_STOP	= 0x67	#!< Z    stop VM

#OP_GETSV	= 0x15	#!< BB   R(a) = Special[Syms(b)]
#OP_SETSV	= 0x16	#!< BB   Special[Syms(b)] = R(a)
#OP_GETCV	= 0x19	#!< BB   R(a) = cvget(Syms(b))
#OP_SETCV	= 0x1a	#!< BB   cvset(Syms(b),R(a))
#OP_GETMCNST	= 0x1d	#!< BB   R(a) = R(a)::Syms(b)
#OP_SETMCNST	= 0x1e	#!< BB   R(a+1)::Syms(b) = R(a)
#OP_EXCEPT	= 0x26	#!< B    R(a) = exc
#OP_RESCUE	= 0x27	#!< BB   R(b) = R(a).isa?(R(b))
#OP_POPERR	= 0x28	#!< B    a.times{rescue_pop()}
#OP_RAISE	= 0x29	#!< B    raise(R(a))
#OP_EPUSH	= 0x2a	#!< B    ensure_push(SEQ[a])
#OP_EPOP	= 0x2b	#!< B    A.times{ensure_pop().call}
#OP_SENDVB	= 0x2d	#!< BB   R(a) = call(R(a),Syms(b),*R(a+1),&R(a+2))
#OP_CALL	= 0x30	#!< Z    R(0) = self.call(frame.argc, frame.argv)
#OP_KEY_P	= 0x34	#!< BB   R(a) = kdict.key?(Syms(b))                      # todo
#OP_KEYEND	= 0x35	#!< Z    raise unless kdict.empty?                       # todo
#OP_KARG	= 0x36	#!< BB   R(a) = kdict[Syms(b)]; kdict.delete(Syms(b))    # todo
#OP_ARYPUSH	= 0x49	#!< B    ary_push(R(a),R(a+1))
#OP_ASET	= 0x4c	#!< BBB  R(a)[c] = R(b)
#OP_HASHADD	= 0x52	#!< BB   R(a) = hash_push(R(a),R(a+1)..R(a+b))
#OP_HASHCAT	= 0x53	#!< B    R(a) = hash_cat(R(a),R(a+1))
#OP_LAMBDA	= 0x54	#!< BB   R(a) = lambda(SEQ[b],L_LAMBDA)
#OP_OCLASS	= 0x59	#!< B    R(a) = ::Object
#OP_MODULE	= 0x5b	#!< BB   R(a) = newmodule(R(a),Syms(b))
#OP_UNDEF	= 0x5f	#!< B    undef_method(target_class,Syms(a))
#OP_DEBUG	= 0x62	#!< BBB  print a,b,c
#OP_ERR	= 0x63,	#!< B    raise(LocalJumpError, Lit(a))

  OP_ABORT	= 0x68
end
