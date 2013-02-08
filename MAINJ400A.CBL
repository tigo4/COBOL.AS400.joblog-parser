       IDENTIFICATION DIVISION.
       PROGRAM-ID. MAINJ400A.
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
           SELECT ECHODSP ASSIGN TO WORKSTATION-MAINSCREEN
                   ORGANIZATION IS TRANSACTION
                   ACCESS IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
        FD ECHODSP.
         01 RECDSP.
         Copy DDS-ALL-FORMATS OF MAINSCREEN.
       WORKING-STORAGE SECTION.
       77   IND-OFF                       PIC 1  VALUE B"0".
       77   IND-ON                        PIC 1  VALUE B"1".
       01   WS-INDICATORS.
             05 IN03                      PIC 1  INDIC 03.
             05 IN70                      PIC 1  INDIC 70.
             05 IN71                      PIC 1  INDIC 71.
             05 IN72                      PIC 1  INDIC 72.
             05 IN73                      PIC 1  INDIC 73.
             05 IN74                      PIC 1  INDIC 74.
       01  ERROR1                          PIC X(50).
       PROCEDURE DIVISION.
       MAINRTN.
            OPEN I-O ECHODSP
            INITIALIZE RMAINSCR-I
            INITIALIZE RMAINSCR-O
            MOVE 'QPJOBLOG' TO SFROMFILE OF RMAINSCR-I
            PERFORM SHOWSCREEN UNTIL IN03 OF WS-INDICATORS = IND-ON.
            CLOSE ECHODSP.
            STOP RUN.
       SHOWSCREEN.
            WRITE RECDSP FORMAT IS 'RMAINSCR'
                    INDICATORS ARE WS-INDICATORS
            READ ECHODSP
                    INDICATORS ARE WS-INDICATORS
            MOVE IND-OFF TO IN71 OF WS-INDICATORS
            MOVE IND-OFF TO IN72 OF WS-INDICATORS
            MOVE IND-OFF TO IN73 OF WS-INDICATORS
            MOVE IND-OFF TO IN74 OF WS-INDICATORS
            IF SFROMFILE OF RMAINSCR-I = SPACES
              MOVE IND-ON TO IN71 OF WS-INDICATORS
            END-IF.
            IF SJOBNAME  OF RMAINSCR-I = SPACES
              MOVE IND-ON TO IN72 OF WS-INDICATORS
            END-IF.
            IF SJOBNBR   OF RMAINSCR-I = SPACES
              MOVE IND-ON TO IN73 OF WS-INDICATORS
            END-IF.
      *     IF SFILENBR  OF RMAINSCR-I = SPACES
      *       MOVE IND-ON TO IN74 OF WS-INDICATORS
      *     END-IF.
            IF IN71 OF WS-INDICATORS = IND-OFF AND
               IN72 OF WS-INDICATORS = IND-OFF AND
               IN73 OF WS-INDICATORS = IND-OFF AND
               IN74 OF WS-INDICATORS = IND-OFF AND
               IN03 OF WS-INDICATORS = IND-OFF
            PERFORM CALLPARSER
            END-IF.
       CALLPARSER.
            MOVE SPACES TO ERROR1
            CALL 'PARSERDO' USING SFROMFILE OF RMAINSCR-I
                                  SJOBNAME  OF RMAINSCR-I
                                  SJOBNBR   OF RMAINSCR-I
                                  SFILENBR  OF RMAINSCR-I
                                  BY REFERENCE ERROR1.
            MOVE IND-OFF TO IN70.
            MOVE SPACES TO MSG OF RMAINSCR-O.
            IF ERROR1 NOT = SPACES
               MOVE IND-ON TO IN70
               MOVE ERROR1 TO MSG OF RMAINSCR-O
            ELSE
               CALL 'MSFL'
            END-IF.
