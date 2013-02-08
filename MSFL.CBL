       IDENTIFICATION DIVISION.
       PROGRAM-ID. MSFL.
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
           SELECT DSPSFL ASSIGN TO WORKSTATION-MSFLSCREEN
                   ORGANIZATION IS TRANSACTION
                   ACCESS MODE IS DYNAMIC
                   RELATIVE KEY IS RELKEY
                   FILE STATUS IS SFLSTATUS.
           SELECT FILE1 ASSIGN TO DISK-JOBLOGF.
       DATA DIVISION.
       FILE SECTION.
        FD DSPSFL
             LABEL RECORDS ARE STANDARD.
         01 RECSFLCTL.
               COPY DDS-ALL-FORMATS OF MSFLSCREEN.
        FD FILE1.
         01 RECFILE.
               Copy DDS-ALL-FORMATS OF JOBLOGF.
         88 EOFFILE                     VALUE B"1".
       WORKING-STORAGE SECTION.
       77   IND-OFF                       PIC 1       VALUE B"0".
       77   IND-ON                        PIC 1       VALUE B"1".
       01   SEQ1                          PIC X(10).
       01   COUNTER                       PIC 9(10).
       01   SFLSTATUS                     PIC 99.
       01   RELKEY                        PIC 9(10)   VALUE ZEROES.
       01   END1                          PIC 9(10)   VALUE ZEROES.
       01   WS-INDICATORS.
         05  IN17                   PIC 1 INDIC 17.
         05  IN18                   PIC 1 INDIC 18.
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
       PROCEDURE DIVISION.
       MAINPROC.
            INITIALIZE RELKEY END1
            SET NOT-END-PROGRAM TO TRUE
            OPEN I-O DSPSFL
            OPEN INPUT FILE1
            SET NO-SUBFILE-DISPLAY TO TRUE.
            SET NO-SUBFILE-CONTROL TO TRUE.
            SET NOT-SUBFILE-END TO TRUE.
            SET SUBFILE-CLEAR TO TRUE.
            WRITE RECSFLCTL FROM RSFLCTL-O FORMAT IS "RSFLCTL"
            SET NOT-SUBFILE-CLEAR TO TRUE.
            READ FILE1
                AT END SET EOFFILE TO TRUE
            END-READ.
            PERFORM UNTIL EOFFILE
               MOVE SEQ OF RECFILE TO SEQ OF RSFL-I
               MOVE MSGID OF RECFILE TO MSGID OF RSFL-I
               MOVE MSGTYP OF RECFILE TO MSGTYP OF RSFL-I
               MOVE MSGSEV OF RECFILE TO MSGSEV OF RSFL-I
               MOVE MSGDATE OF RECFILE TO MSGDATE OF RSFL-I
               MOVE MSGHORA OF RECFILE TO MSGHORA OF RSFL-I
               MOVE MSGTSEQ OF RECFILE TO MSGTSEQ OF RSFL-I
               MOVE FROMPGM OF RECFILE TO FROMPGM OF RSFL-I
               MOVE FROMPGMLIB OF RECFILE TO FROMPGMLIB OF RSFL-I
               MOVE FROMPGMINS OF RECFILE TO FROMPGMINS OF RSFL-I
               MOVE MSGTOPGM OF RECFILE TO MSGTOPGM OF RSFL-I
               MOVE MSGTOPGLIB OF RECFILE TO MSGTOPGLIB OF RSFL-I
               MOVE TOPGMINS OF RECFILE TO TOPGMINS OF RSFL-I
               ADD 1 TO RELKEY
               ADD 1 TO END1
               WRITE SUBFILE RECSFLCTL FROM RSFL-O FORMAT "RSFL"
                   INDICATORS ARE WS-INDICATORS
               READ FILE1
                   AT END SET EOFFILE TO TRUE
               END-READ
            END-PERFORM.
            SET SUBFILE-END TO TRUE.
            MOVE 1 TO RELKEY
            PERFORM SHOWSCREEN UNTIL END-PROGRAM.
            CLOSE FILE1
            CLOSE DSPSFL.
            GOBACK.
       SHOWSCREEN.
            WRITE RECSFLCTL FORMAT IS "HEADER".
            WRITE RECSFLCTL FORMAT IS "FOOTER".
            SET SUBFILE-CONTROL TO TRUE
            SET SUBFILE-DISPLAY TO TRUE
            MOVE RELKEY TO RRN OF RSFLCTL-O
            IF IN18 = IND-ON
                MOVE END1 TO RRN OF RSFLCTL-O
            END-IF
            IF IN17 = IND-ON
                MOVE 1 TO RRN OF RSFLCTL-O
            END-IF
            WRITE RECSFLCTL FROM RSFLCTL-O FORMAT "RSFLCTL"
                INDICATORS ARE WS-INDICATORS.
      *     MOVE 1 TO RRN OF RSFLCTL-O
            READ DSPSFL
                INDICATORS ARE WS-INDICATORS.
            SET NOT-END-SUBFILE TO TRUE
            IF END1 = 0
              SET END-SUBFILE TO TRUE
            END-IF
            PERFORM READSFL UNTIL END-SUBFILE.
       READSFL.
            READ SUBFILE DSPSFL NEXT MODIFIED
                 INTO RSFL-I FORMAT IS 'RSFL'
                 INDICATORS ARE WS-INDICATORS
                 AT END
                   SET END-SUBFILE TO TRUE
                 NOT AT END
                   IF OPT OF RSFL-I = 'X'
                    MOVE SPACES TO OPT OF RSFL-I
                    REWRITE SUBFILE RECSFLCTL FROM RSFL-O FORMAT 'RSFL'
                     INDICATORS ARE WS-INDICATORS
                    MOVE SEQ OF RSFL-I TO SEQ1
                    CALL 'WND' USING SEQ1
                                     MSGID OF RSFL-I
                   END-IF
            END-READ.
