import { Logger } from 'log-core'

const root = new Logger('SatsAuth', { color: 'cyan' })

export const zitadel = root.child('Zitadel')
