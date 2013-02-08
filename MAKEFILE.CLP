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
     PGM        PARM(&LIB)
     DCL        VAR(&LIB)  TYPE(*CHAR) LEN(10)

     CHKOBJ     OBJ(*LIBL/&LIB) OBJTYPE(*LIB)
     MONMSG     MSGID(CPF9801) EXEC(DO)
        SNDPGMMSG MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('error: library +
         not found in *LIBL') TOPGMQ(*EXT) MSGTYPE(*INFO)
        GOTO       CMDLBL(ENDER)
     ENDDO

     SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('build of +
     AS400.joblog-parser started') TOPGMQ(*EXT) MSGTYPE(*INFO)

     CRTPF FILE(&LIB/JOBLOGQ) +
             SRCFILE(&LIB/AS400JLA) +
             SRCMBR(JOBLOGQ) +
               SIZE(*NOMAX)
     MONMSG     MSGID(CPF7302) EXEC( +
     SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('object file JOBLOGQ +
     found') TOPGMQ(*EXT) MSGTYPE(*INFO))

     CRTPF FILE(&LIB/JOBLOGF) +
             SRCFILE(&LIB/AS400JLA) +
             SRCMBR(JOBLOGF) +
               SIZE(*NOMAX)
     MONMSG     MSGID(CPF7302) EXEC( +
     SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('object file JOBLOGF +
     found') TOPGMQ(*EXT) MSGTYPE(*INFO))

     CRTPF FILE(&LIB/JOBLOGFD) +
             SRCFILE(&LIB/AS400JLA) +
             SRCMBR(JOBLOGFD) +
               SIZE(*NOMAX)
     MONMSG     MSGID(CPF7302) EXEC( +
     SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('object file JOBLOGFD +
     found') TOPGMQ(*EXT) MSGTYPE(*INFO))

       CRTSQLRPGI OBJ(&LIB/PARSER) +
                  SRCFILE(&LIB/AS400JLA) +
                  SRCMBR(PARSER) +
                  COMMIT(*NONE) +
                  OBJTYPE(*PGM) +
                  REPLACE(*YES)

       CRTCLPGM PGM(&LIB/PARSERDO) +
                SRCFILE(&LIB/AS400JLA) +
                SRCMBR(PARSERDO) +
                REPLACE(*YES)

       CRTDSPF FILE(&LIB/MAINSCREEN) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(MAINSCREEN) +
                 REPLACE(*YES)

       CRTCBLPGM PGM(&LIB/MAINJ400A) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(MAINJ400A) +
                 REPLACE(*YES)

       CRTDSPF FILE(&LIB/MSFLSCREEN) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(MSFLSCREEN) +
                 REPLACE(*YES)

       CRTCBLPGM PGM(&LIB/MSFL) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(MSFL) +
                 REPLACE(*YES)

       CRTDSPF FILE(&LIB/WNDSCREEN) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(WNDSCREEN) +
                 REPLACE(*YES)

       CRTBNDCBL PGM(&LIB/WND) +
                 SRCFILE(&LIB/AS400JLA) +
                 SRCMBR(WND) +
                 REPLACE(*YES)
 END:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('build +
             complete. "===> CALL MAINJ400A"') +
                          TOPGMQ(*EXT) +
                          MSGTYPE(*INFO)
                 RETURN
 ENDER:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('build +
                          abnormally completed') TOPGMQ(*EXT) +
                          MSGTYPE(*INFO)
                 RETURN

                 ENDPGM
