  /* @                                                               */
  /* devsoftprog.AS400.joblog-parser                                 */
  /* Copyright (c) 2011,2012,2013 tigo                               */
  /* MIT License (MIT)                                               */
  /* @                                                               */
  /* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR */
  /* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, */
  /* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE */
  /* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER */
  /* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, */
  /* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN */
  /* THE SOFTWARE.                                                   */
  /* @                                                               */
  /*         change log:                                             */
  /*                                                                 */
  /*                 Apr2011                                         */
  /*                                                                 */
  /* @                                                               */
  /*                                                                 */
             PGM        PARM(&FROMFILE &JOBNAME &JOBNBR &FILENBR +
                             &ERROR)
             DCL        VAR(&FROMFILE)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNAME)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNBR)    TYPE(*CHAR) LEN(10)
             DCL        VAR(&FILENBR)   TYPE(*CHAR) LEN(10)
             DCL        VAR(&ERROR) TYPE(*CHAR) LEN(50) VALUE(SPACES)
             IF         COND(&FILENBR *EQ '          ') +
             THEN(DO)
                CPYSPLF FILE(&FROMFILE) TOFILE(JOBLOGQ) +
                  JOB(&JOBNBR/*N/&JOBNAME)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(ERROR1))
                MONMSG     MSGID(CPF3342) EXEC(GOTO CMDLBL(ERROR1))
                MONMSG     MSGID(CPF3303) EXEC(GOTO CMDLBL(ERROR2))
                MONMSG     MSGID(CPF3340) EXEC(GOTO CMDLBL(ERROR3))
             ENDDO
             ELSE DO
                CPYSPLF FILE(&FROMFILE) TOFILE(JOBLOGQ) +
                  JOB(&JOBNBR/*N/&JOBNAME) +
                  SPLNBR(&FILENBR)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(ERROR1))
                MONMSG     MSGID(CPF3342) EXEC(GOTO CMDLBL(ERROR1))
                MONMSG     MSGID(CPF3303) EXEC(GOTO CMDLBL(ERROR2))
                MONMSG     MSGID(CPF3340) EXEC(GOTO CMDLBL(ERROR3))
             ENDDO
             CALL PARSER
             GOTO       CMDLBL(END)
ERROR1:
             CHGVAR VAR(&ERROR) VALUE('ERROR: job not found')
             GOTO       CMDLBL(END)
ERROR2:
             CHGVAR VAR(&ERROR) VALUE('ERROR: file not found in Job')
             GOTO       CMDLBL(END)
ERROR3:
             CHGVAR VAR(&ERROR) VALUE('ERROR: missing file number  ')
END:
             RETURN
             ENDPGM
