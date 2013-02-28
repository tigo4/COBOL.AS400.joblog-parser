       IDENTIFICATION DIVISION.
       PROGRAM-ID. WND.
      * @
      * devsoftprog.AS400.joblog-parser
      * Copyright (c) 2011,2012,2013 tigo
      * MIT License (MIT)
      * @
      * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      * THE SOFTWARE.
      * @
      *         change log:
      *
      *                 Apr2011
      *
      * @
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
         SOURCE-COMPUTER. IBM-AS400.
         OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DSPSFL ASSIGN TO WORKSTATION-WNDSCREEN
                   ORGANIZATION IS TRANSACTION
                   ACCESS MODE IS DYNAMIC
                   RELATIVE KEY IS RELKEY
                   FILE STATUS IS SFLSTATUS.
           SELECT FILE1 ASSIGN TO DISK-JOBLOGFD.
       DATA DIVISION.
       FILE SECTION.
        FD DSPSFL.
         01 RECSFLCTL.
           COPY DDS-ALL-FORMATS OF WNDSCREEN.
        FD FILE1.
         01   RECFILE.
           COPY DDS-ALL-FORMATS OF JOBLOGFD.
         88   EOFFILE                     VALUE B"1".
       WORKING-STORAGE SECTION.
       77   IND-OFF                       PIC 1       VALUE B"0".
       77   IND-ON                        PIC 1       VALUE B"1".
       01   PSEQ                          PIC 9(10).
       01   FIRSTCHAR                     PIC 9(3).
       01   I                             PIC 9(3).
       01   CNT                           PIC 9(3).
       01   MSGA                          PIC X(132).
         05  MSG1                         PIC X(76).
         05  MSG2                         PIC X(62).
       01   COUNTER                       PIC 99.
       01   SFLSTATUS                     PIC 99.
       01   RELKEY                        PIC 9(3)    VALUE ZEROES.
       01   WS-INDICATORS.
         05  IN61                   PIC 1 INDIC 61.
             88 END-SUBFILE         VALUE B"1".
             88 NOT-END-SUBFILE     VALUE B"0".
         05  IN03                   PIC 1 INDIC 03.
             88 END-PROGRAM         VALUE B"1".
             88 NOT-END-PROGRAM     VALUE B"0".
         05  IN31                   PIC 1 INDIC 31.
             88 SUBFILE-DISPLAY     VALUE B"1".
             88 NO-SUBFILE-DISPLAY  VALUE B"0".
         05  IN32                   PIC 1 INDIC 32.
             88 SUBFILE-CONTROL     VALUE B"1".
             88 NO-SUBFILE-CONTROL  VALUE B"0".
         05  IN33                   PIC 1 INDIC 33.
             88 SUBFILE-END         VALUE B"1".
             88 NOT-SUBFILE-END     VALUE B"0".
         05  IN34                   PIC 1 INDIC 34.
             88 SUBFILE-CLEAR       VALUE B"1".
             88 NOT-SUBFILE-CLEAR   VALUE B"0".
       LINKAGE SECTION.
        01 SEQ1    PIC X(10).
        01 PMSGID  PIC X(07).
       PROCEDURE DIVISION USING SEQ1
                                PMSGID.
       MAINPROC.
            COMPUTE PSEQ = FUNCTION NUMVAL(SEQ1).
            OPEN I-O DSPSFL
            OPEN INPUT FILE1
            SET NO-SUBFILE-DISPLAY TO TRUE.
            SET NO-SUBFILE-CONTROL TO TRUE.
            SET NOT-SUBFILE-END TO TRUE.
            SET SUBFILE-CLEAR TO TRUE.
            WRITE RECSFLCTL FROM RSFLCTL-O FORMAT IS "RSFLCTL"
            SET NOT-SUBFILE-CLEAR TO TRUE.
            WRITE RECSFLCTL FROM RSFLCTL-O FORMAT IS "RSFLCTL"
            READ FILE1
                AT END SET EOFFILE TO TRUE
            END-READ.
            PERFORM UNTIL EOFFILE
               IF SEQ = PSEQ
                  MOVE 1 TO FIRSTCHAR
                  PERFORM VARYING I FROM 1 BY 1
                   UNTIL I > LENGTH OF MSGLINES OR FIRSTCHAR > 1
                      IF MSGLINES(I:1) NOT = SPACE
                         MOVE I TO FIRSTCHAR
                      END-IF
                  END-PERFORM
                  SUBTRACT FIRSTCHAR FROM 131 GIVING CNT
                  MOVE MSGLINES (FIRSTCHAR:CNT) TO MSGA
                  MOVE MSG1 TO MSGLINES1 OF RSFL-I
                  MOVE MSG2 TO MSGLINES2 OF RSFL-I
                  ADD 1 TO RELKEY
                  WRITE SUBFILE RECSFLCTL FROM RSFL-O FORMAT "RSFL"
                  INDICATORS ARE WS-INDICATORS
               END-IF
               READ FILE1
                     AT END SET EOFFILE TO TRUE
               END-READ
            END-PERFORM.
            SET SUBFILE-END TO TRUE.
      *     PERFORM SHOWSCREEN UNTIL END-PROGRAM.
            PERFORM SHOWSCREEN.
            CLOSE FILE1
            CLOSE DSPSFL.
            STOP RUN.
       SHOWSCREEN.
            SET SUBFILE-CONTROL TO TRUE
            SET SUBFILE-DISPLAY TO TRUE
            MOVE 1 TO RRN OF RSFLCTL-O
            MOVE 1 TO RELKEY
            MOVE PMSGID TO SMSGID OF RSFLCTL-O
            WRITE RECSFLCTL FROM RSFLCTL-O FORMAT "RSFLCTL"
                INDICATORS ARE WS-INDICATORS.
            READ DSPSFL
                INDICATORS ARE WS-INDICATORS.
