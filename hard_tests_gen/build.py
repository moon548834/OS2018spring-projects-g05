#!/usr/bin/env python3

import os
import errno
import itertools

# Require mipsel-linux-gnu installed in PATH
# If you are using other tool chain, change this
XCOMPILER = 'mipsel-linux-gnu'

TEMPLATE_DIR = 'template/'
SRC_DIR = 'tests/'
OUT_DIR = 'output/'

''' Compile assembly into hexadecimal VHDL literal '''
def genHexInst(s):
    print("[DEBUG] assembling %s"%(s))
    with open('.tmp.s', 'w') as f:
        f.write(s + '\n')
    if os.system('%s-as -mips32 .tmp.s -o .tmp.o 2>&1 | awk \'{print "as: " $0}\''%(XCOMPILER)):
        raise Exception("Assembling failed")
    if os.system('%s-objcopy -j .text -O binary .tmp.o .tmp.bin 2>&1 | awk \'{print "objcopy: " $0}\''%(XCOMPILER)):
        raise Exception("Assembling failed")
    with open('.tmp.bin', 'rb') as f:
        hexStr = '_'.join(map(lambda byte: '%02x'%(byte), f.read(4)))
        return 'x"%s"'%(hexStr)

''' Generate the VHDL statements for {{{INIT_INST_RAM}}} '''
def genInitInstRam(runCmd):
    stmts = ['-- CODE BELOW IS AUTOMATICALLY GENERATED']
    for i, cmd in zip(itertools.count(), runCmd):
        stmts.append('words(%d) <= %s; -- RUN %s'%(i, genHexInst(cmd), cmd))
    return '\n'.join(stmts)

''' Generate the VHDL statements for {{{ASSERTIONS}}} '''
def genAssertions(assertCmd):
    stmts = ['-- CODE BELOW IS AUTOMATICALLY GENERATED']
    for lhs, rhs in assertCmd:
        stmts.append('wait for CLK_PERIOD;\nassert user_%s = %s severity FAILURE;'%(lhs, rhs))
    return '\n'.join(stmts)

''' Generate the VHDL statements for {{{ALIASES}}} '''
def genAliases(defineCmd):
    stmts = ['-- CODE BELOW IS AUTOMATICALLY GENERATED']
    for alias, hierarchy in defineCmd:
        stmts.append('alias user_%s is <<signal cpu_inst.%s>>;'%(alias, hierarchy))
    return '\n'.join(stmts)

''' Parse test file and return (RUN instructions, ASSERT pairs, DEFINE pairs) '''
def parse(filename):
    runCmd = []
    assertCmd = []
    defineCmd = []
    with open(SRC_DIR + filename) as f:
        for line in f:
            line = line.rstrip()
            if line.split() == []:
                continue
            if line[0] == '#':
                continue
            op, param = line.split(None, 1)
            if op == 'RUN':
                runCmd.append(param)
            elif op == 'ASSERT':
                assertCmd.append(param.split(None, 1))
            elif op == 'DEFINE':
                defineCmd.append(param.split(None, 1))
            else:
                raise Exception("Unrecognized op '%s'"%(op))
    return (runCmd, assertCmd, defineCmd)

templateNames = ['tb.vhd', 'fake_ram.vhd', 'test_const.vhd']
templates = {}

for name in templateNames:
    with open(TEMPLATE_DIR + name) as f:
        templates[name] = f.read();

for testCase in os.listdir(SRC_DIR):
    if testCase[0] == '.': # Might be editor temporary files
        continue
    runCmd, assertCmd, defineCmd = parse(testCase)
    initInstRam = genInitInstRam(runCmd)
    assertions = genAssertions(assertCmd)
    aliases = genAliases(defineCmd)

    try:
        os.makedirs(OUT_DIR + testCase)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

    for name in templateNames:
        out = templates[name]
        out = out.replace("{{{NOTICE}}}", "-- DO NOT MODIFY THIS FILE.\n-- This file is generated by hard_tests_gen")
        out = out.replace("{{{TEST_NAME}}}", testCase)
        out = out.replace("{{{INIT_INST_RAM}}}", initInstRam)
        out = out.replace("{{{ASSERTIONS}}}", assertions)
        out = out.replace("{{{ALIASES}}}", aliases)
        outputName = name if name != 'template.vhd' else testCase + '.vhd'
        with open("%s/%s/%s"%(OUT_DIR, testCase, "%s_%s"%(testCase, outputName)), 'w') as outFile:
            outFile.write(out)

