/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "%d // %d";
static const char *ng1 = "D:/Faculty/WorkSpace/Xillinx/comips1/shiftconst.v";
static unsigned int ng2[] = {25U, 0U};
static unsigned int ng3[] = {100U, 0U};

void Monitor_34_1(char *);
void Monitor_34_1(char *);


static void Monitor_34_1_Func(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;

LAB0:    t1 = (t0 + 1448);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = (t0 + 1048U);
    t5 = *((char **)t4);
    xsi_vlogfile_write(1, 0, 3, ng0, 3, t0, (char)118, t3, 32, (char)118, t5, 32);

LAB1:    return;
}

static void Initial_32_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;

LAB0:    t1 = (t0 + 2368U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(33, ng1);

LAB4:    xsi_set_current_line(34, ng1);
    Monitor_34_1(t0);
    xsi_set_current_line(35, ng1);
    t2 = (t0 + 2176);
    xsi_process_wait(t2, 5000LL);
    *((char **)t1) = &&LAB5;

LAB1:    return;
LAB5:    xsi_set_current_line(36, ng1);
    t3 = ((char*)((ng2)));
    t4 = (t0 + 1448);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    xsi_set_current_line(37, ng1);
    t2 = (t0 + 2176);
    xsi_process_wait(t2, 5000LL);
    *((char **)t1) = &&LAB6;
    goto LAB1;

LAB6:    xsi_set_current_line(38, ng1);
    t3 = ((char*)((ng3)));
    t4 = (t0 + 1448);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 32);
    goto LAB1;

}

void Monitor_34_1(char *t0)
{
    char *t1;
    char *t2;

LAB0:    t1 = (t0 + 2424);
    t2 = (t0 + 2936);
    xsi_vlogfile_monitor((void *)Monitor_34_1_Func, t1, t2);

LAB1:    return;
}


extern void work_m_00000000004242358065_2032643945_init()
{
	static char *pe[] = {(void *)Initial_32_0,(void *)Monitor_34_1};
	xsi_register_didat("work_m_00000000004242358065_2032643945", "isim/tb_shift_isim_beh.exe.sim/work/m_00000000004242358065_2032643945.didat");
	xsi_register_executes(pe);
}
