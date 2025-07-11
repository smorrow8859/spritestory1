*       = $8000

; Found on Youtube
; Title: Commodore 128D: Episode 3: Hardware Sprites
; Channel: Nybbles and Bytes

        lda #13
        sta $d020  ; border color
        jsr $e544
        jsr spritestory
        
        lda #%11111111
        sta $d015  ; enable sprite
        lda #%11111111
        sta $d01c  ; activate multicolor bits
        lda #2
        sta $d025  ; sprite multicolor reg #1
        lda #6
        sta $d026  ; sprite color #0
        lda #$05
        sta $d027  ; sprite color #1
        lda #$06
        sta $d028

        lda #0
        sta $d021  ; background color

        lda #24
        sta $d000  ;sprite horizontal(X) position
        lda #122
        sta $d001  ;sprite vertical(Y) position

        lda #24
        sta $d002  ;sprite horizontal(X) position
        lda #143
        sta $d003   ;sprite horizontal(Y) position

        lda #$c0
        sta $7f8  ; sprite shape pointer
        lda #$c1
        sta $7f9  ; sprite shape pointer
        sta shape

; show sprite 3 in corner: 4567
        lda #$f9
        sta $d026  ; sprite multicolor reg #0

        lda #$05
        sta $d027  ; sprite #0 color
        lda #7
        sta $d028  ; sprite #1 color

        lda #7
        sta $d029  ; sprite #2 color
        lda #6
        sta $d02a  ; sprite #3 color

        lda #255
        sta $d004  ;sprite 2 X coordinate
        lda #122
        sta $d005  ;sprite 2 Y coordinate
 
        lda #255
        sta $d006  ;sprite 3 X coordinate
        lda #143
        sta $d007  ;sprite 3 Y coordinate

        lda #$d2   ; sprite 1 shape data pointer (201)
        sta $7fa
        lda #$d3   ; sprite 1 shape data pointer
        sta $7fb
;        rts
        

; draw ground under sprite
        ldx #$28
draw_grnd
        lda #102
        sta $062f,x
        lda #13
        sta 55855,x
        lda #78
        sta 1623,x
        lda #3
        sta 55895,x
        lda #77
        sta 1663,x
        lda #86
        sta 1703,x
        lda #5
        sta 55975,x
        dex
        bne draw_grnd

start
        tax
        tay
        sty $fb
spr_loop

        stx $d000 ; move sprite X from left to right
        stx $d000 ; move sprite X from left to right
        stx $d002
        stx $d002
        iny
        bne spr_loop

        jsr InitRasterIRQ

        lda shapecount

; shape: Cycles through 193,195,197

        lda shapecount          ; count from 0-2
        cmp #198                  ; get 3 sprite shapes
        bcc skip_anim 


update_anim
        lda #193
        sta shapecount
        lda #$c1                ; 193

skip_anim
        sta $7f9
;        sta shapecount
        
        lda count
        and #15
        cmp #8
        bne waitchange
        lda #1
        sta count

        inc shapecount          ; increase to 194
        inc shapecount          ; increase to 195

waitchange
        inc count
        inx
        bne spr_loop

        lda $d010 ; check Sprite X MSB

;        and #$03  ; Flip the Sprite we care about
;        eor #$01  ; Toggle the MSB for Sprite 0
;        sta $d010
        bcs no_msbset ; skip if msb is not set

        lda #1
        sta $d010

        inc $d020
        sta $d021
        inc $d027  ; store in sprite color

        lda $d000
        cmp #10
        bcc no_msbset
        lda #24
        sta $d000
        sta $d002

no_msbset
        jmp start

delay1
        lda $d012
        cmp #$fe
        beq delay1

delay2
        lda $d012
        cmp #$fe
        bne delay2
        rts

InitRasterIRQ
        sei                     ; stop all interrupts
        lda $001
        
        lda #$7f                ; disable cia #1 generating timer irqs
        sta $dc0d

        lda #$01                ; tell the VIC we want to generate raster irqs
        sta $d01a

        lda #$32                ; number of the rasterline we want the IRQ to occur at
        sta $d012     

        lda #<FirstIrq
        sta $0314
        lda #>FirstIrq
        sta $0315

        lda $dc0d
        lda $dd0d
        cli                     ; turn interrupts back on
        rts

FirstIrq
        sei                    ; acknowledge VIC irq
        lda $D019
        sta $D019 
        
        lda #$c7
        sta $D012
        jsr delay1
        cli
        jmp $ea31

spritestory
        ldx #0
        
writewords
        lda story,x
;        ora #4
        sta 1030,x
        lda #1
        sta 55302,x
        inx
        cpx #27
        bne writewords
        rts

shapecount byte 193
count   byte 1

story   text "SPRITE STORIES. COMING SOON."

        * = $3000

incbin"school/SpriteKids.bin",1,5,true

incbin"school/SpriteKidsAttribs.bin",true       
