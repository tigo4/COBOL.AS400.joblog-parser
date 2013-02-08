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
     H OPTION(*NodebugIO : *SRCSTMT)
      ****                                   date format (ddmmyy)
     H DATEDIT(*DMY) DATFMT(*ISO)
      *
      *                                      joblog input file
     FJOBLOGQ   IF   E           K DISK
      *                                      output file header
     FJOBLOGF   UF A E           K DISK
      *                                      output file detail
     FJOBLOGFD  UF A E           K DISK
      *
      *                                      data structures
     D PGMINFO        SDS
     D  §PGMNAME               1     10
     D  §PARMS                37     39  0
     D  §MSGID                40     46
     D  §JOBNAME             244    253
     D  §USERID              254    263
     D  §JOBNUMBER           264    269  0
      *
     D $SRCDTA         DS
     D   MSGID                        7A   Overlay($SRCDTA:1)
     D   MSGTYP                      24A   Overlay($SRCDTA:12)
     D   MSGSEV                       2A   Overlay($SRCDTA:36)
     D   MSGDATE                      8A   Overlay($SRCDTA:41)
     D   MSGHORA                      8A   Overlay($SRCDTA:51)
     D   MSGTSEQ                      6A   Overlay($SRCDTA:60)
     D   FROMPGM                     10A   Overlay($SRCDTA:68)
     D   FROMPGMLIB                  10A   Overlay($SRCDTA:81)
     D   FROMPGMINS                   7A   Overlay($SRCDTA:93)
     D   MSGTOPGM                    10A   Overlay($SRCDTA:102)
     D   MSGTOPGLIB                  10A   Overlay($SRCDTA:114)
     D   TOPGMINS                     7A   Overlay($SRCDTA:124)
      *
      *   variables
     D i1              S              5U 0
     D i2              S              5U 0
     D i9              S              5U 0
      *
     D #LetUC          C                   Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D #LetLC          C                   Const('abcdefghijklmnopqrstuvwxyz')
      *
      *** main *********************************************
      *
     C/exec SQL
     C+    DELETE FROM JOBLOGF
     C/end-exec
      *
     C/exec SQL
     C+    DELETE FROM JOBLOGFD
     C/end-exec
      *
     C                   EXSR      DUMP
      *
     C                   SETON                                        LR
      *
      ******************* end main *************************
      *
     C     DUMP          BEGSR
      *
     C                   CLEAR                   SEQ
      *
     C     *START        SETLL     JOBLOGQ
      *
     C                   READ(E)   JOBLOGQ
      *
     C                   DOW       NOT %EOF(JOBLOGQ)
      *
      /free

         $SRCDTA = LINES;

      /end-free
      *
     C****               IF        MSGID<>*BLANKS
     C****               IF        MSGID<>*BLANKS AND %subst(MSGID:1:1)<>*BLANKS
     C****                         AND %subst(MSGID:1:1)<>'I'
     C****                         AND %subst(MSGID:1:1)<>'I'
      *
     C                   IF        %subst(LINES:43:1)='/'
     C                             AND %subst(LINES:46:1)='/'
     C                             AND %subst(LINES:53:1)=':'
     C                             AND %subst(LINES:56:1)=':'
     C                   ADD       1             SEQ
     C                   WRITE     RJOBLOGF
     C                   ELSE
      *
     C                   IF        MSGID=*BLANKS
     C                   MOVE      LINES         MSGLINES
     C                   WRITE     RJOBLOGFD
     C                   ENDIF
      *
     C                   ENDIF
      *
     C                   READ(E)   JOBLOGQ
      *
     C                   ENDDO
      *
     C                   ENDSR
      *
