	.text
# -- Begin  putc
	.p2align 4,,15
	.globl putc
	.type	putc, @function
putc:
/*.L0:*/                          /* Block BB[51:2] preds: none, freq: 1.000 */
	lui	x7, 131072                   /* riscv_lui Iu[274:9] io.c:3:25 */
	slli	x6, x10, 24                 /* riscv_slli Iu[276:11] io.c:5:14 */
	srai	x6, x6, 24                  /* riscv_srai Iu[277:12] io.c:5:14 */
	sw	x6, 0(x7)                     /* riscv_sw M[278:13] io.c:5:5 */
	ret                              /* riscv_ret X[304:39] */
	.size	putc, .-putc
# -- End  putc

# -- Begin  puti
	.p2align 4,,15
	.globl puti
	.type	puti, @function
puti:
/*.L200:*/                        /* Block BB[72:2] preds: none, freq: 1.000 */
	addi	x2, x2, -16                 /* be_IncSP Iu[735:387] */
	sw	x24, 0(x2)                    /* riscv_sw M[624:280] */
	sw	x25, 4(x2)                    /* riscv_sw M[621:277] */
	sw	x26, 8(x2)                    /* riscv_sw M[618:274] */
	sw	x27, 12(x2)                   /* riscv_sw M[615:271] */
	mv	x24, x22                      /* be_Copy Iu[713:369] */
	mv	x22, x21                      /* be_Copy Iu[714:370] */
	mv	x21, x20                      /* be_Copy Iu[715:371] */
	mv	x20, x19                      /* be_Copy Iu[716:372] */
	mv	x19, x18                      /* be_Copy Iu[717:373] */
	mv	x18, x9                       /* be_Copy Iu[718:374] */
	mv	x9, x8                        /* be_Copy Iu[719:375] */
	mv	x8, x1                        /* be_Copy Iu[720:376] */
	mv	x25, x10                      /* be_Copy Iu[721:377] */
	addi	x27, x0, 28                 /* riscv_addi Iu[416:78] io.c:15:14 */
	addi	x26, x0, 9                  /* riscv_addi Iu[418:80] */
	j .L201                          /* riscv_j X[387:49] */
.L202:                            /* Block BB[106:54] preds: .L203, freq: 5.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[396:58] */
	addi	x1, x1, 48                  /* riscv_addi Iu[401:63] io.c:20:22 */
	slli	x1, x1, 24                  /* riscv_slli Iu[402:64] */
	srai	x10, x1, 24                 /* riscv_srai Iu[403:65] */
	jal	putc                         /* riscv_jal T[404:66] io.c:20:17 */
	addi	x2, x2, 8                   /* be_IncSP Iu[406:68] */
	/* fallthrough to .L204 */       /* riscv_j X[393:55] */
.L204:                            /* Block BB[124:47] preds: .L202 .L205, freq: 10.000 */
	addi	x27, x27, -4                /* riscv_addi Iu[417:79] io.c:15:32 */
	/* fallthrough to .L201 */       /* riscv_j X[388:50] */
.L201:                            /* Block BB[84:9] preds: .L200 .L204, freq: 11.000 */
	bge	x27, x0, .L203               /* riscv_bcc T[390:52] io.c:15:20 */
	/* fallthrough to .L206 */       /* riscv_bcc T[390:52] io.c:15:20 */
.L206:                            /* Block BB[93:11] preds: .L201, freq: 1.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[350:12] */
	addi	x1, x0, 10                  /* riscv_addi Iu[352:14] io.c:28:10 */
	slli	x1, x1, 24                  /* riscv_slli Iu[353:15] */
	srai	x10, x1, 24                 /* riscv_srai Iu[354:16] */
	jal	putc                         /* riscv_jal T[355:17] io.c:28:9 */
	mv	x1, x8                        /* be_Copy Iu[722:378] */
	mv	x8, x9                        /* be_Copy Iu[723:379] */
	mv	x9, x18                       /* be_Copy Iu[724:380] */
	mv	x18, x19                      /* be_Copy Iu[725:381] */
	mv	x19, x20                      /* be_Copy Iu[726:382] */
	mv	x20, x21                      /* be_Copy Iu[727:383] */
	mv	x21, x22                      /* be_Copy Iu[728:384] */
	mv	x22, x24                      /* be_Copy Iu[729:385] */
	addi	x2, x2, 8                   /* be_IncSP Iu[357:19] */
	lw	x27, 12(x2)                   /* riscv_lw T[616:272] */
	lw	x26, 8(x2)                    /* riscv_lw T[619:275] */
	lw	x25, 4(x2)                    /* riscv_lw T[622:278] */
	lw	x24, 0(x2)                    /* riscv_lw T[625:281] */
	addi	x2, x2, 16                  /* be_IncSP Iu[734:386] */
	ret                              /* riscv_ret X[384:46] */
.L203:                            /* Block BB[92:59] preds: .L201, freq: 10.000 */
	sra	x1, x25, x27                 /* riscv_sra Iu[399:61] io.c:17:16 */
	andi	x1, x1, 15                  /* riscv_andi Iu[400:62] io.c:17:22 */
	bge	x26, x1, .L202               /* riscv_bcc T[419:81] io.c:18:15 */
	/* fallthrough to .L205 */       /* riscv_bcc T[419:81] io.c:18:15 */
.L205:                            /* Block BB[107:56] preds: .L203, freq: 5.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[408:70] */
	addi	x1, x1, 55                  /* riscv_addi Iu[409:71] io.c:24:27 */
	slli	x1, x1, 24                  /* riscv_slli Iu[410:72] */
	srai	x10, x1, 24                 /* riscv_srai Iu[411:73] */
	jal	putc                         /* riscv_jal T[412:74] io.c:24:17 */
	addi	x2, x2, 8                   /* be_IncSP Iu[414:76] */
	j .L204                          /* riscv_j X[395:57] */
	.size	puti, .-puti
# -- End  puti

