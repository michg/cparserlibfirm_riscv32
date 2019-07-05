	.text
# -- Begin  putc
	.p2align 4,,15
	.globl putc
	.type	putc, @function
putc:
/*.L0:*/                          /* Block BB[51:2] preds: none, freq: 1.000 */
	lui	x7, 256                      /* riscv_lui Iu[273:9] iopulp.c:3:6 */
	slli	x6, x10, 24                 /* riscv_slli Iu[275:11] iopulp.c:3:34 */
	srai	x6, x6, 24                  /* riscv_srai Iu[276:12] iopulp.c:3:34 */
	sw	x6, 0(x7)                     /* riscv_sw M[277:13] iopulp.c:3:5 */
	ret                              /* riscv_ret X[303:39] */
	.size	putc, .-putc
# -- End  putc

# -- Begin  puti
	.p2align 4,,15
	.globl puti
	.type	puti, @function
puti:
/*.L200:*/                        /* Block BB[71:2] preds: none, freq: 1.000 */
	addi	x2, x2, -16                 /* be_IncSP Iu[734:387] */
	sw	x24, 0(x2)                    /* riscv_sw M[623:280] */
	sw	x25, 4(x2)                    /* riscv_sw M[620:277] */
	sw	x26, 8(x2)                    /* riscv_sw M[617:274] */
	sw	x27, 12(x2)                   /* riscv_sw M[614:271] */
	mv	x24, x22                      /* be_Copy Iu[712:369] */
	mv	x22, x21                      /* be_Copy Iu[713:370] */
	mv	x21, x20                      /* be_Copy Iu[714:371] */
	mv	x20, x19                      /* be_Copy Iu[715:372] */
	mv	x19, x18                      /* be_Copy Iu[716:373] */
	mv	x18, x9                       /* be_Copy Iu[717:374] */
	mv	x9, x8                        /* be_Copy Iu[718:375] */
	mv	x8, x1                        /* be_Copy Iu[719:376] */
	mv	x25, x10                      /* be_Copy Iu[720:377] */
	addi	x27, x0, 28                 /* riscv_addi Iu[415:78] iopulp.c:13:14 */
	addi	x26, x0, 9                  /* riscv_addi Iu[417:80] */
	j .L201                          /* riscv_j X[386:49] */
.L202:                            /* Block BB[105:54] preds: .L203, freq: 5.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[395:58] */
	addi	x1, x1, 48                  /* riscv_addi Iu[400:63] iopulp.c:18:22 */
	slli	x1, x1, 24                  /* riscv_slli Iu[401:64] */
	srai	x10, x1, 24                 /* riscv_srai Iu[402:65] */
	jal	putc                         /* riscv_jal T[403:66] iopulp.c:18:17 */
	addi	x2, x2, 8                   /* be_IncSP Iu[405:68] */
	/* fallthrough to .L204 */       /* riscv_j X[392:55] */
.L204:                            /* Block BB[123:47] preds: .L202 .L205, freq: 10.000 */
	addi	x27, x27, -4                /* riscv_addi Iu[416:79] iopulp.c:13:32 */
	/* fallthrough to .L201 */       /* riscv_j X[387:50] */
.L201:                            /* Block BB[83:9] preds: .L200 .L204, freq: 11.000 */
	bge	x27, x0, .L203               /* riscv_bcc T[389:52] iopulp.c:13:20 */
	/* fallthrough to .L206 */       /* riscv_bcc T[389:52] iopulp.c:13:20 */
.L206:                            /* Block BB[92:11] preds: .L201, freq: 1.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[349:12] */
	addi	x1, x0, 10                  /* riscv_addi Iu[351:14] iopulp.c:26:10 */
	slli	x1, x1, 24                  /* riscv_slli Iu[352:15] */
	srai	x10, x1, 24                 /* riscv_srai Iu[353:16] */
	jal	putc                         /* riscv_jal T[354:17] iopulp.c:26:9 */
	mv	x1, x8                        /* be_Copy Iu[721:378] */
	mv	x8, x9                        /* be_Copy Iu[722:379] */
	mv	x9, x18                       /* be_Copy Iu[723:380] */
	mv	x18, x19                      /* be_Copy Iu[724:381] */
	mv	x19, x20                      /* be_Copy Iu[725:382] */
	mv	x20, x21                      /* be_Copy Iu[726:383] */
	mv	x21, x22                      /* be_Copy Iu[727:384] */
	mv	x22, x24                      /* be_Copy Iu[728:385] */
	addi	x2, x2, 8                   /* be_IncSP Iu[356:19] */
	lw	x27, 12(x2)                   /* riscv_lw T[615:272] */
	lw	x26, 8(x2)                    /* riscv_lw T[618:275] */
	lw	x25, 4(x2)                    /* riscv_lw T[621:278] */
	lw	x24, 0(x2)                    /* riscv_lw T[624:281] */
	addi	x2, x2, 16                  /* be_IncSP Iu[733:386] */
	ret                              /* riscv_ret X[383:46] */
.L203:                            /* Block BB[91:59] preds: .L201, freq: 10.000 */
	sra	x1, x25, x27                 /* riscv_sra Iu[398:61] iopulp.c:15:16 */
	andi	x1, x1, 15                  /* riscv_andi Iu[399:62] iopulp.c:15:22 */
	bge	x26, x1, .L202               /* riscv_bcc T[418:81] iopulp.c:16:15 */
	/* fallthrough to .L205 */       /* riscv_bcc T[418:81] iopulp.c:16:15 */
.L205:                            /* Block BB[106:56] preds: .L203, freq: 5.000 */
	addi	x2, x2, -8                  /* be_IncSP Iu[407:70] */
	addi	x1, x1, 55                  /* riscv_addi Iu[408:71] iopulp.c:22:27 */
	slli	x1, x1, 24                  /* riscv_slli Iu[409:72] */
	srai	x10, x1, 24                 /* riscv_srai Iu[410:73] */
	jal	putc                         /* riscv_jal T[411:74] iopulp.c:22:17 */
	addi	x2, x2, 8                   /* be_IncSP Iu[413:76] */
	j .L204                          /* riscv_j X[394:57] */
	.size	puti, .-puti
# -- End  puti

