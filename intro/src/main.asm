                    !cpu 6510
; ==============================================================================
ENABLE              = 0x20
ENABLE_JMP          = 0x4C
DISABLE             = 0x2C
OP_RTS              = 0x60
OP_NOP              = 0xEA

BLACK               = 0x00
WHITE               = 0x01
RED                 = 0x02
CYAN                = 0x03
PURPLE              = 0x04
GREEN               = 0x05
BLUE                = 0x06
YELLOW              = 0x07
ORANGE              = 0x08
BROWN               = 0x09
PINK                = 0x0A
DARK_GREY           = 0x0B
GREY                = 0x0C
LIGHT_GREEN         = 0x0D
LIGHT_BLUE          = 0x0E
LIGHT_GREY          = 0x0F
; ------------------------------------------------------------------------------
;                   BADLINEs (0xD011 default)
;                   -------------------------
;                   00 : 0x33
;                   01 : 0x3B
;                   02 : 0x43
;                   03 : 0x4B
;                   04 : 0x53
;                   05 : 0x5B
;                   06 : 0x63
;                   07 : 0x6B
;                   08 : 0x73
;                   09 : 0x7B
;                   10 : 0x83
;                   11 : 0x8B
;                   12 : 0x93
;                   13 : 0x9B
;                   14 : 0xA3
;                   15 : 0xAB
;                   16 : 0xB3
;                   17 : 0xBB
;                   18 : 0xC3
;                   19 : 0xCB
;                   20 : 0xD3
;                   21 : 0xDB
;                   22 : 0xE3
;                   23 : 0xEB
;                   24 : 0xF3
; ------------------------------------------------------------------------------
IRQ_LINE00          = 0x00
IRQ_LINE01          = 0xF8
; ==============================================================================
zp_start            = 0x02
irq_ready_top       = zp_start
irq_ready_bot       = irq_ready_top+1
savea               = irq_ready_bot+1
savex               = savea+1
savey               = savex+1
save1               = savey+1
frame_ct_0          = save1+1
frame_ct_1          = frame_ct_0+1
frame_ct_2          = frame_ct_1+1
; ==============================================================================
KEY_CRSRUP          = 0x91
KEY_CRSRDOWN        = 0x11
KEY_CRSRLEFT        = 0x9D
KEY_CRSRRIGHT       = 0x1D
KEY_RETURN          = 0x0D
KEY_STOP            = 0x03

getin               = 0xFFE4
keyscan             = 0xEA87
; ==============================================================================
code_start          = 0x2000
vicbank0            = 0x0000
charset0            = vicbank0+0x1800
vidmem0             = vicbank0+0x0400
sprite_data         = vicbank0+0x0C00
sprite_base         = <((sprite_data-vicbank0)/0x40)
dd00_val0           = <!(vicbank0/0x4000) & 3
d018_val0           = <(((vidmem0-vicbank0)/0x400) << 4)+ <(((charset0-vicbank0)/0x800) << 1)
music_init          = 0x1000
music_play          = music_init+3
; ==============================================================================
                    !macro flag_set .flag {
                        lda #1
                        sta .flag
                    }
                    !macro flag_clear .flag {
                        lda #0
                        sta .flag
                    }
                    !macro flag_get .flag {
                        lda .flag
                    }
; ==============================================================================
                    *= music_init
                    !bin "sid/introtune.mus"
; ==============================================================================
                    *= code_start
                    lda #0x7F
                    sta 0xDC0D
                    lda #0x35
                    sta 0x01
                    lda #0x1B
                    sta 0xD011
; ==============================================================================
                    !zone INIT
init_code:          jsr init_nmi
                    jsr init_zp
                    jsr init_music
                    jsr basicfade
                    jsr init_vic
                    jsr init_irq
                    jmp mainloop
; ------------------------------------------------------------------------------
init_irq:           lda irq_lines
                    sta 0xD012
                    sta irq_plus_cmp+1
                    inc irq_plus_cmp+1
                    lda #<irq
                    sta 0xFFFE
                    lda #>irq
                    sta 0xFFFF
                    lda #0x0B
                    sta 0xD011
                    lda #0x01
                    sta 0xD019
                    sta 0xD01A
                    rts
; ------------------------------------------------------------------------------
init_music:         lda #0x00
                    tax
                    tay
                    jsr music_init
                    rts
; ------------------------------------------------------------------------------
init_nmi:           lda #<nmi
                    sta 0x0318
                    sta 0xFFFA
                    lda #>nmi
                    sta 0x0319
                    sta 0xFFFB
                    rts
; ------------------------------------------------------------------------------
init_vic:           lda #dd00_val0
                    sta 0xDD00
                    lda #d018_val0
                    sta 0xD018
                    rts
; ------------------------------------------------------------------------------
init_zp:            lda #0x00
                    ldx #zp_start
-                   sta 0x00,x
                    inx
                    bne -
                    rts
; ==============================================================================
                    !zone NMI
nmi:                lda #0x37               ; restore 0x01 standard value
                    sta 0x01
                    lda #0                  ; if AR/RR present
                    sta 0xDE00              ; reset will lead to menu
                    jmp 0xFCE2              ; reset
; ==============================================================================
                    !zone WAIT
wait_irq_top:       +flag_clear irq_ready_top
-                   +flag_get irq_ready_top
                    beq -
                    rts
; --------------------------------------------------------------------------------
wait_irq_bot:       +flag_clear wait_irq_bot
-                   +flag_get wait_irq_bot
                    beq -
                    rts
; ==============================================================================
                    !zone MAINLOOP
mainloop:           jsr wait_irq_top
                    jmp mainloop
; ==============================================================================
                    !zone FRAME_COUNT
framecounter:       clc
                    lda frame_ct_0
                    adc #1
                    sta frame_ct_0
                    lda frame_ct_1
                    adc #0
                    sta frame_ct_1
                    lda frame_ct_2
                    adc #0
                    sta frame_ct_2
                    rts
; ==============================================================================
                    !zone BASICFADE
                    BASICFADE_SPEED = 0x04
basicfade:          lda 0xD020
                    and #0x0F
                    tax
                    lda .colfade_wh_tab_lo,x
                    sta .src_d020+1
                    lda .colfade_wh_tab_hi,x
                    sta .src_d020+2
                    lda 0xD021
                    and #0x0F
                    tax
                    lda .colfade_wh_tab_lo,x
                    sta .src_d021+1
                    lda .colfade_wh_tab_hi,x
                    sta .src_d021+2
                    ; fade 0xD020 / 0xD021 seperate to white first
                    ldy #0x00
-                   ldx #BASICFADE_SPEED
                    jsr .wait_top_x
                    jsr .set_d020
                    jsr .set_d021
                    iny
.ct:                lda #0x02
                    bne -
                    ; and then both to black
                    ldy #0xFF
-                   iny
                    ldx #BASICFADE_SPEED
                    jsr .wait_top_x
                    lda .colfade_bl_tab,y
                    sta 0xD020
                    sta 0xD021
                    bpl -
                    lda #0x0B
                    sta 0xD011
                    rts
; ------------------------------------------------------------------------------
.set_d020:          nop
.src_d020:          lda 0x0000,y
                    sta 0xD020
                    bpl +
                    lda #OP_RTS
                    sta .set_d020
                    dec .ct+1
+                   rts
; ------------------------------------------------------------------------------
.set_d021:          nop
.src_d021:          lda 0x0000,y
                    sta 0xD021
                    bpl +
                    lda #OP_RTS
                    sta .set_d021
                    dec .ct+1
+                   rts
; ------------------------------------------------------------------------------
.colfade_bl_tab:    !byte 0x01, 0x0D, 0x03, 0x0C, 0x04, 0x02, 0x09, 0xF0
.colfade_wh_tab0:   !byte 0x00, 0x06, 0x0B, 0x04, 0x0C, 0x03, 0x0D, 0xF1
.colfade_wh_tab1:   !byte 0x09, 0x02, 0x08, 0x0A, 0x0F, 0x07, 0xF1
.colfade_wh_tab2:   !byte 0x05, 0x03, 0x0D, 0xF1
.colfade_wh_tab3:   !byte 0x0E, 0x03, 0x0D, 0xF1
.colfade_wh_tab_lo: !byte <(.colfade_wh_tab0+0)     ; 0x00 BLACK
                    !byte <(.colfade_wh_tab0+7)     ; 0x01 WHITE
                    !byte <(.colfade_wh_tab1+1)     ; 0x02 RED
                    !byte <(.colfade_wh_tab0+5)     ; 0x03 CYAN
                    !byte <(.colfade_wh_tab0+3)     ; 0x04 PURPLE
                    !byte <(.colfade_wh_tab2+0)     ; 0x05 GREEN
                    !byte <(.colfade_wh_tab0+1)     ; 0x06 BLUE
                    !byte <(.colfade_wh_tab1+5)     ; 0x07 YELLOW
                    !byte <(.colfade_wh_tab1+2)     ; 0x08 ORANGE
                    !byte <(.colfade_wh_tab1+0)     ; 0x09 BROWN
                    !byte <(.colfade_wh_tab1+3)     ; 0x0A PINK
                    !byte <(.colfade_wh_tab0+2)     ; 0x0B DARK_GREY
                    !byte <(.colfade_wh_tab0+4)     ; 0x0C GREY
                    !byte <(.colfade_wh_tab0+6)     ; 0x0D LIGHT_GREEN
                    !byte <(.colfade_wh_tab3+0)     ; 0x0E LIGHT_BLUE
                    !byte <(.colfade_wh_tab1+4)     ; 0x0F LIGHT_GREY
.colfade_wh_tab_hi: !byte >(.colfade_wh_tab0+0)     ; 0x00 BLACK
                    !byte >(.colfade_wh_tab0+7)     ; 0x01 WHITE
                    !byte >(.colfade_wh_tab1+1)     ; 0x02 RED
                    !byte >(.colfade_wh_tab0+5)     ; 0x03 CYAN
                    !byte >(.colfade_wh_tab0+3)     ; 0x04 PURPLE
                    !byte >(.colfade_wh_tab2+0)     ; 0x05 GREEN
                    !byte >(.colfade_wh_tab0+1)     ; 0x06 BLUE
                    !byte >(.colfade_wh_tab1+5)     ; 0x07 YELLOW
                    !byte >(.colfade_wh_tab1+2)     ; 0x08 ORANGE
                    !byte >(.colfade_wh_tab1+0)     ; 0x09 BROWN
                    !byte >(.colfade_wh_tab1+3)     ; 0x0A PINK
                    !byte >(.colfade_wh_tab0+2)     ; 0x0B DARK_GREY
                    !byte >(.colfade_wh_tab0+4)     ; 0x0C GREY
                    !byte >(.colfade_wh_tab0+6)     ; 0x0D LIGHT_GREEN
                    !byte >(.colfade_wh_tab3+0)     ; 0x0E LIGHT_BLUE
                    !byte >(.colfade_wh_tab1+4)     ; 0x0F LIGHT_GREY
; ------------------------------------------------------------------------------
.wait_top:          bit 0xD011
                    bpl .wait_top
-                   bit 0xD011
                    bmi -
                    rts
; ------------------------------------------------------------------------------
; .wait_top_x
; ------------+---+-------------------------------------------------------------
; input:      | X | number of frames to wait
; ------------+---+-------------------------------------------------------------
.wait_top_x:        jsr .wait_top
                    dex
                    bpl .wait_top_x
                    rts
; ==============================================================================
                    !zone IRQ
                    NUM_IRQS = 0x01
                    !align 255,0
irq:                sta savea               ; 03  10  (07+03)
                    stx savex               ; 03  13
                    sty savey               ; 03  16
                    lda 0x01                ; 03  19
                    sta save1               ; 03  22
                    lda #<.irq_timing       ; 02  24
                    sta 0xFFFE              ; 04  26
                    lda #>.irq_timing       ; 02  28
                    sta 0xFFFF              ; 04  32
                    inc 0xD012              ; 06  38
                    asl 0xD019              ; 06  44
                    tsx                     ; 02  46
                    cli                     ; 02  48
                    !fi 8, 0xEA             ; 02  64  (08*02)
.irq_timing:        txs
                    ldx #0x08
-                   dex
                    bne -
                    bit 0xEA
                    nop
irq_plus_cmp:       lda #<IRQ_LINE00+1
                    cmp 0xD012
                    beq irq_next
irq_next:           jmp irq00
; ------------------------------------------------------------------------------
irq_end:            lda 0xD012
-                   cmp 0xD012
                    beq -
.irq_index:         ldx #0x00
                    lda irq_tab_lo,x
                    sta irq_next+1
                    lda irq_tab_hi,x
                    sta irq_next+2
                    lda irq_lines,x
                    sta 0xD012
                    sta irq_plus_cmp+1
                    inc irq_plus_cmp+1
                    inc .irq_index+1
                    lda .irq_index+1
                    cmp #NUM_IRQS
                    bne +
                    lda #0x00
                    sta .irq_index+1
+                   lda #<irq
                    sta 0xFFFE
                    lda #>irq
                    sta 0xFFFF
                    asl 0xD019
                    lda save1
                    sta 0x01
                    lda savea
                    ldx savex
                    ldy savey
                    rti
irq_tab_lo:         !byte <irq00, <irq01
irq_tab_hi:         !byte >irq00, >irq01
irq_lines:          !byte IRQ_LINE00, IRQ_LINE01
; ------------------------------------------------------------------------------
                    !align 255,0
irq00:              +flag_set irq_ready_top
                    jsr framecounter
enable_music:       jsr music_play
                    jmp irq_end
; ------------------------------------------------------------------------------
irq01:              +flag_set irq_ready_bot
                    jmp irq_end
; ==============================================================================
code_end:
