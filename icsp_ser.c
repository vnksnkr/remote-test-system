
/*	PIC32MZ ICSP Serial Interface
**
**	Copyright (C) 2018-2019 Herbert Poetzl
**
**	This program is free software; you can redistribute it and/or modify
**    	it under the terms of the GNU General Public License 2 as published 
**	by the Free Software Foundation.
**
*/


#include <xc.h>
#include <stdint.h>
#include <stdbool.h>


#define NEW_VERSION  1
	// DEVCFG0
#pragma config BOOTISA = MIPS32
#pragma config ICESEL = ICS_PGx1
#pragma config FECCCON = OFF_UNLOCKED
#pragma config FSLEEP = 0

	// DEVCFG1
#pragma	config FDMTEN = OFF
#pragma	config FWDTEN = OFF
#pragma config POSCMOD = OFF
#pragma config OSCIOFNC = ON
#pragma config FSOSCEN = OFF
#pragma config FNOSC = SPLL
#pragma config FCKSM = CSECMD

	// DEVCFG2
#pragma config FPLLICLK = PLL_FRC
#pragma config FPLLIDIV = DIV_2
#pragma config FPLLRNG = RANGE_5_10_MHZ
#pragma config FPLLMULT = MUL_100
#pragma config FPLLODIV = DIV_4
//#pragma config UPLLEN = OFF
#pragma config UPLLFSEL = FREQ_24MHZ

	// DEVCFG3
#pragma config USERID = 0xC0DE
#pragma config FMIIEN = OFF
#pragma config PGL1WAY = OFF
#pragma config PMDL1WAY = OFF
#pragma config IOL1WAY = OFF
#pragma config FUSBIDIO = OFF

	// DEVCP0
#pragma config CP = OFF


static bool sel = 0;

static uint32_t hexval = 0;
static uint32_t hexdat = 0;


#define ICSP_W_MCLR_O	LATCbits.LATC13
#define ICSP_W_MCLR_T	TRISCbits.TRISC13

#if 0
#define	ICSP_W_PCLK_O	LATGbits.LATG7
#define	ICSP_W_PCLK_T	TRISGbits.TRISG7

#define	ICSP_W_PDAT_O	LATGbits.LATG8
#define ICSP_W_PDAT_I	PORTGbits.RG8
#define ICSP_W_PDAT_T	TRISGbits.TRISG8
#else
#define	ICSP_W_PCLK_O	LATFbits.LATF8
#define	ICSP_W_PCLK_T	TRISFbits.TRISF8
#define ICSP_W_PCLK_U	CNPUFbits.CNPUF8

#define	ICSP_W_PDAT_O	LATFbits.LATF2
#define ICSP_W_PDAT_I	PORTFbits.RF2
#define ICSP_W_PDAT_T	TRISFbits.TRISF2
#define ICSP_W_PDAT_U	CNPUFbits.CNPUF2
#endif


#define ICSP_E_MCLR_O	LATCbits.LATC14
#define ICSP_E_MCLR_T	TRISCbits.TRISC14


#if NEW_VERSION 
#define	ICSP_E_PCLK_O	LATFbits.LATF5
#define	ICSP_E_PCLK_T	TRISFbits.TRISF5
#define	ICSP_E_PCLK_U	CNPUFbits.CNPUF5
#define	ICSP_E_PDAT_O	LATFbits.LATF4
#define ICSP_E_PDAT_I	PORTFbits.RF4
#define ICSP_E_PDAT_T	TRISFbits.TRISF4
#define ICSP_E_PDAT_U	CNPUFbits.CNPUF4
#else

#define	ICSP_E_PCLK_O	LATAbits.LATA2
#define	ICSP_E_PCLK_T	TRISAbits.TRISA2
#define	ICSP_E_PCLK_U	CNPUAbits.CNPUA2
#define	ICSP_E_PDAT_O	LATAbits.LATA3
#define ICSP_E_PDAT_I	PORTAbits.RA3
#define ICSP_E_PDAT_T	TRISAbits.TRISA3
#define ICSP_E_PDAT_U	CNPUAbits.CNPUA3

#endif


static inline
void	unlock(void)
{
	SYSKEY = 0xAA996655;
	SYSKEY = 0x556699AA;
}

static inline
void	lock(void)
{
	SYSKEY = 0x33333333;
}

static inline
void	irq_disable(void)
{
	asm volatile("di");
	asm volatile("ehb");
}

static inline
void	irq_enable(void)
{
	asm volatile("ei");
}


void	init_pbus(void)
{
	unlock();
	PB2DIVbits.PBDIV = 0b000001;	// divide by 2
	PB2DIVbits.ON = 1;

	PB7DIVbits.PBDIV = 0b000000;	// divide by 1
	PB7DIVbits.ON = 1;
	lock();
}


void	init_icsp_w(void)
{
	ICSP_W_MCLR_T = 0;		// MCLR out
	ICSP_W_PCLK_T = 0;		// PCLK out
	ICSP_W_PDAT_T = 0;		// PDAT out

	ANSELGbits.ANSG7 = 0;		// digital
	ANSELGbits.ANSG8 = 0;		// digital

	I2C3CONbits.ON = 0;		// disable I2C
}


void	init_icsp_e(void)
{
	ICSP_E_MCLR_T = 0;		// MCLR out
	ICSP_E_PCLK_T = 0;		// PCLK out
	ICSP_E_PDAT_T = 0;		// PDAT out

	I2C2CONbits.ON = 0;		// disable I2C
}


void	init_i2c_e(void)
{
	ICSP_E_PCLK_U = 1;
	ICSP_E_PDAT_U = 1;

	I2C2BRG = 128;

	I2C2ADD = 0xFF;
	I2C2MSK = 0xFF;
	
	ICSP_E_PDAT_O = 0;		// clear SDA
	ICSP_E_PDAT_T = 0;		// SDA to out
	ICSP_E_PCLK_O = 1;		// set SCL
	ICSP_E_PCLK_T = 1;		// SCL to in

	I2C2CONbits.ON = 1;
}

void	init_i2c_w(void)
{
	ICSP_W_PCLK_U = 1;
	ICSP_W_PDAT_U = 1;

	I2C3ADD = 0xFF;
	I2C3MSK = 0xFF;

	I2C3BRG = 128;

	ICSP_W_PDAT_O = 0;		// clear SDA
	ICSP_W_PDAT_T = 0;		// SDA to out
	ICSP_W_PCLK_O = 1;		// set SCL
	ICSP_W_PCLK_T = 1;		// SCL to in

	I2C3CONbits.ON = 1;
}



void	init_uart2(void)
{
	irq_disable();

	U2MODEbits.ON = 0;

	TRISEbits.TRISE8 = 0;		// U2TX out
	TRISEbits.TRISE9 = 1;		// U2RX in
	ANSELEbits.ANSE8 = 0;		// digital
	ANSELEbits.ANSE9 = 0;		// digital

	CFGCONbits.IOLOCK = 0;
	RPE8Rbits.RPE8R = 0b0010;	// U2TX
	U2RXRbits.U2RXR = 0b1101;	// RPE9
	CFGCONbits.IOLOCK = 1;

	INTCONbits.MVEC = 1;		// Multi Vector Interrupts
	PRISSbits.SS0 = 0;		// Normal Register Set
	PRISSbits.PRI7SS = 7;		// Assign Shadow Register Set

	IPC36bits.U2TXIP = 7;		// Interrupt priority of 7
	IPC36bits.U2TXIS = 0;		// Interrupt sub-priority of 0
	IPC36bits.U2RXIP = 7;		// Interrupt priority of 7
	IPC36bits.U2RXIS = 0;		// Interrupt sub-priority of 0

	IEC4SET = _IEC4_U2RXIE_MASK;	// Rx INT Enable
	IFS4bits.U2TXIF = 0;		// Clear Tx flag
	IFS4bits.U2RXIF = 0;		// Clear Rx flag

	U2BRG = 24;			// 1MBaud @ 50MHz
	U2STA = 0;
	
	U2MODEbits.BRGH = 1;
	U2MODEbits.PDSEL = 0b00;
	U2MODEbits.STSEL = 0;
	U2MODEbits.UEN = 0b00;
	U2MODEbits.ON = 1;
	U2STASET = 0x9400;		// Enable Transmit and Receive

	irq_enable();
}


static inline
uint8_t	i2c2_start(void)
{
	I2C2CONbits.SEN = 1;		// Send Start
	while (I2C2CONbits.SEN);
	return I2C2STAT & 0xFF;
}

static inline
uint8_t	i2c3_start(void)
{
	I2C3CONbits.SEN = 1;		// Send Start
	while (I2C3CONbits.SEN);
	return I2C3STAT & 0xFF;
}

static inline
uint8_t	i2c2_restart(void)
{
	I2C2CONbits.RSEN = 1;		// Send Restart
	while (I2C2CONbits.RSEN);
	return I2C2STAT & 0xFF;
}

static inline
uint8_t	i2c3_restart(void)
{
	I2C3CONbits.RSEN = 1;		// Send Restart
	while (I2C3CONbits.RSEN);
	return I2C3STAT & 0xFF;
}


static inline
uint8_t	i2c2_stop(void)
{
	if ((I2C2CON & 0x1F) == 0)
	    I2C2CONbits.PEN = 1;	// Send Stop
	return I2C2CON & 0x1F;
}


static inline
uint8_t	i2c3_stop(void)
{
	if ((I2C3CON & 0x1F) == 0)
	    I2C3CONbits.PEN = 1;	// Send Stop
	return I2C3CON & 0x1F;
}

static inline
void	i2c_bb_delay(unsigned cnt)
{
	unsigned i;
	while (cnt--)
	    for (i=0; i<200; i++);
}

static inline
void	i2c2_bb_stop(void)
{
	i2c_bb_delay(1);
	I2C2CONbits.ON = 0;		// disable I2C
	i2c_bb_delay(1);
	ICSP_E_PDAT_T = 1;		// SDA to input
	i2c_bb_delay(2);
	I2C2CONbits.ON = 1;		// enable I2C
	ICSP_E_PDAT_O = 0;		// clear SDA
	ICSP_E_PDAT_T = 0;		// SDA to out
	ICSP_E_PCLK_O = 1;		// set SCL
	ICSP_E_PCLK_T = 1;		// SCL to in
}

static inline
void	i2c3_bb_stop(void)
{
	i2c_bb_delay(1);
	I2C3CONbits.ON = 0;		// disable I2C
	i2c_bb_delay(1);
	ICSP_W_PDAT_T = 1;		// SDA to input
	i2c_bb_delay(2);
	I2C3CONbits.ON = 1;		// enable I2C
	ICSP_W_PDAT_O = 0;		// clear SDA
	ICSP_W_PDAT_T = 0;		// SDA to out
	ICSP_W_PCLK_O = 1;		// set SCL
	ICSP_W_PCLK_T = 1;		// SCL to in
}


static inline
bool	i2c2_write(uint8_t byte)
{
	I2C2TRN = byte;
	while (I2C2STATbits.TRSTAT);
	return I2C2STATbits.ACKSTAT;
}

static inline
bool	i2c3_write(uint8_t byte)
{
	I2C3TRN = byte;
	while (I2C3STATbits.TRSTAT);
	return I2C3STATbits.ACKSTAT;
}

static inline
uint8_t	i2c2_read(bool ackdt)
{
	while (I2C2STATbits.RBF)
	    (void)I2C2RCV;
	if (I2C2CON & 0x1F)
	    return 0xFF;

	I2C2CONbits.RCEN = 1;
	while (!I2C2STATbits.RBF);

	I2C2CONbits.ACKDT = ackdt;
	I2C2CONbits.ACKEN = 1;
	while (I2C2CONbits.ACKEN);

	return I2C2RCV;
}

static inline
uint8_t	i2c3_read(bool ackdt)
{
	while (I2C3STATbits.RBF)
	    (void)I2C3RCV;
	if (I2C3CON & 0x1F)
	    return 0xFF;

	I2C3CONbits.RCEN = 1;
	while (!I2C3STATbits.RBF);

	I2C3CONbits.ACKDT = ackdt;
	I2C3CONbits.ACKEN = 1;
	while (I2C3CONbits.ACKEN);

	return I2C3RCV;
}



static inline
void	icsp_w_mclr(unsigned val)
{
	ICSP_W_PDAT_T = 0;
	ICSP_W_MCLR_O = (val & 1) ? 1 : 0;
	ICSP_W_PCLK_O = (val & 2) ? 1 : 0;
	ICSP_W_PDAT_O = (val & 4) ? 1 : 0;
}

static inline
void	icsp_w_out(uint32_t val, unsigned len)
{
	while (len) {
	    bool bit = val & 1;

	    ICSP_W_PCLK_O = 1;
	    ICSP_W_PDAT_O = bit;
	    val >>= 1;
	    ICSP_W_PCLK_O = 0;
	    len--;
	}
}

static inline
uint32_t icsp_w_in(unsigned len)
{
	uint32_t val = 0;
	unsigned shift = 32 - len;

	ICSP_W_PDAT_T = 1;
	while (len) {
	    ICSP_W_PCLK_O = 1;
	    val >>= 1;
	    len--;

	    bool bit = ICSP_W_PDAT_I;

	    ICSP_W_PCLK_O = 0;
	    val |= bit ? (1<<31) : 0;
	}
	ICSP_W_PDAT_T = 0;
	return val >> shift;
}


static inline
void	icsp_e_mclr(unsigned val)
{
	ICSP_E_PDAT_T = 0;
	ICSP_E_MCLR_O = (val & 1) ? 1 : 0;
	ICSP_E_PCLK_O = (val & 2) ? 1 : 0;
	ICSP_E_PDAT_O = (val & 4) ? 1 : 0;
}

static inline
void	icsp_e_out(uint32_t val, unsigned len)
{
	while (len) {
	    bool bit = val & 1;

	    ICSP_E_PCLK_O = 1;
	    ICSP_E_PDAT_O = bit;
	    val >>= 1;
	    ICSP_E_PCLK_O = 0;
	    len--;
	}
}

static inline
uint32_t icsp_e_in(unsigned len)
{
	uint32_t val = 0;
	unsigned shift = 32 - len;

	ICSP_E_PDAT_T = 1;
	while (len) {
	    ICSP_E_PCLK_O = 1;
	    val >>= 1;
	    len--;

	    bool bit = ICSP_E_PDAT_I;

	    ICSP_E_PCLK_O = 0;
	    val |= bit ? (1<<31) : 0;
	}
	ICSP_E_PDAT_T = 0;
	return val >> shift;
}


static inline
void	uart2_ch(char ch)
{
	while (U2STAbits.UTXBF);
	U2TXREG = ch;
}

static inline
void	uart2_hex(uint8_t hex)
{icsp_ser.c:(.vector_146+0x0): undefined reference to `uart2_isr'
	hex &= 0xF;
	if (hex > 9)
	    uart2_ch(hex + 'A' - 10);
	else
	    uart2_ch(hex + '0');
}

static inline
void	uart2_byte(uint8_t val)
{
	uart2_hex(val >> 4);
	uart2_hex(val);
}

static inline
void	uart2_word(uint16_t val)
{
	uart2_byte(val >> 8);
	uart2_byte(val);
}

static inline
void	uart2_long(uint32_t val)
{
	uart2_word(val >> 16);
	uart2_word(val);
}



void __attribute__((vector(_UART2_RX_VECTOR), interrupt(IPL7SRS))) uart2_isr(void)
{
	while (U2STAbits.URXDA) {	// process buffer 
	    char ch = U2RXREG;

	    switch (ch) {
		case '0' ... '9':
		    hexval <<= 4;
		    hexval |= ch - '0';
		    uart2_ch(ch);	// echo back
		    break;
		case 'A' ... 'F':
		    hexval <<= 4;
		    hexval |= ch - 'A' + 10;
		    uart2_ch(ch);	// echo back
		    break;
		case 'a' ... 'f':
		    hexval <<= 4;
		    hexval |= ch - 'a' + 10;
		    uart2_ch(ch);	// echo back
		    break;

		case '#':		// copy val
		    hexdat = hexval;
		    uart2_ch(ch);	// echo back
		    hexval = 0;
		    break;

		case '!':		// select E/W
		    sel = hexval;
		    uart2_ch(ch);	// echo back
		    hexval = 0;
		    break;

		case '=':		// set mclr/pclk/pdat
		    if (sel)
			icsp_e_mclr(hexval);
		    else
			icsp_w_mclr(hexval);
		    uart2_ch(ch);	// echo back
		    hexval = 0;
		    break;

		case '>':		// out icsp seq
		    if (sel)
			icsp_e_out(hexdat, hexval & 0x3F);
		    else
			icsp_w_out(hexdat, hexval & 0x3F);
		    uart2_ch(ch);	// echo back
		    hexval = 0;
		    break;

		case '<':		// out icsp seq
		    if (sel)
			hexdat = icsp_e_in(hexval & 0x1F);
		    else
			hexdat = icsp_w_in(hexval & 0x1F);
		    uart2_ch(ch);	// echo back
		    if (hexval > 16)
			uart2_long(hexdat);
		    else if (hexval > 8)
			uart2_word(hexdat);
		    else 
			uart2_byte(hexdat);
		    hexval = 0;
		    break;

		case '.':		// ignore
		    break;

		case '[':		// switch to I2C
		    if (sel)
			init_i2c_e();
		    else
			init_i2c_w();
		    uart2_ch(ch);	// echo back
		    break;

		case ']':		// back to ICSP
		    if (sel)
			init_icsp_e();
		    else
			init_icsp_w();
		    uart2_ch(ch);	// echo back
		    break;

		case 'S':		// I2C Start
		    if (sel)
			hexdat = i2c2_start();
		    else
			hexdat = i2c3_start();
		    uart2_ch(ch);	// echo back
		    uart2_byte(hexdat);
		    break;

		case 's':		// I2C Retart
		    if (sel)
			hexdat = i2c2_restart();
		    else
			hexdat = i2c3_restart();
		    uart2_ch(ch);	// echo back
		    uart2_byte(hexdat);
		    break;

		case 'P':		// I2C Stop
		    if (sel)
			i2c2_bb_stop();
		    else
			i2c3_bb_stop();
		    uart2_ch(ch);	// echo back
		    break;

		case 'W':
		    if (sel)
			hexdat = i2c2_write(hexval);
		    else
			hexdat = i2c3_write(hexval);
		    uart2_ch(ch);	// echo back
		    uart2_hex(hexdat);
		    hexval = 0;
		    break;

		case 'R':
		    if (sel)
			hexdat = i2c2_read(hexval);
		    else
			hexdat = i2c3_read(hexval);
		    uart2_ch(ch);	// echo back
		    uart2_byte(hexdat);
		    hexval = 0;
		    break;

		default:
		    uart2_ch(ch);	// echo back
	    }
	}
       
	IFS4CLR = _IFS4_U2RXIF_MASK;	// clear UART2 Rx IRQ
}



int	main(void)
{

	TRISGbits.TRISG7 = 0;

	
	init_pbus();
	init_icsp_w();
	init_icsp_e();
	init_uart2();

	while (1)
	    asm volatile("wait");
}
