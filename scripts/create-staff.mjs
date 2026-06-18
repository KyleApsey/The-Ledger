#!/usr/bin/env node
/**
 * One-time script to create a staff member.
 * Outputs the INSERT SQL to paste into the Supabase SQL Editor.
 *
 * Usage:
 *   node scripts/create-staff.mjs --name "Kyle" --pin 1234 --admin
 *   node scripts/create-staff.mjs --name "Belle" --pin 5678
 */

import { createHash } from 'crypto'
import { createRequire } from 'module'

const require = createRequire(import.meta.url)
const bcrypt = require('bcryptjs')

const args = process.argv.slice(2)
const get = (flag) => {
  const i = args.indexOf(flag)
  return i !== -1 ? args[i + 1] : null
}

const name = get('--name')
const pin = get('--pin')
const isAdmin = args.includes('--admin')

if (!name || !pin) {
  console.error('Usage: node scripts/create-staff.mjs --name "Name" --pin 1234 [--admin]')
  process.exit(1)
}

if (!/^\d{4}$/.test(pin)) {
  console.error('Error: PIN must be exactly 4 digits.')
  process.exit(1)
}

const hash = await bcrypt.hash(pin, 10)
const escapedName = name.replace(/'/g, "''")

console.log(`\n-- Run this in the Supabase SQL Editor:\n`)
console.log(`INSERT INTO staff (name, pin_hash, is_admin)`)
console.log(`VALUES ('${escapedName}', '${hash}', ${isAdmin});`)
console.log()
