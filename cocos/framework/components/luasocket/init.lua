--
-- Author: LXL
-- Date: 2015-07-29 14:16:09
--

local package = cc.load("luasocket")

package.socket = import(".socket")
package.ltn12 = import(".ltn12")
package.mime = import(".mime")

package.socket.headers = import(".socket.headers")
package.socket.url = import(".socket.url")
package.socket.tp = import(".socket.tp")
package.socket.ftp = import(".socket.ftp")
package.socket.http = import(".socket.http")
package.socket.smtp = import(".socket.smtp")
package.socket.mbox = import(".socket.mbox")
