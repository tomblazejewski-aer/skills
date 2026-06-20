import type { Plugin } from "@opencode-ai/plugin"

/**
 * Blocks dangerous shell commands that must never run regardless of how they
 * are constructed (e.g. chained with `;`, using `-C <path>`, wrapped in
 * subshells, etc.). Pattern-based permissions in opencode.json cannot reliably
 * catch these because they match only against the start of the command string.
 *
 * Forbidden operations:
 *   - git commit --amend  (history rewrite)
 *   - git push --force / -f / --force-with-lease  (destructive remote push)
 *   - aws  (any AWS CLI invocation)
 */

interface ForbiddenRule {
  /** Human-readable label shown in the denial message. */
  label: string
  /** Regex tested against the full command string. */
  pattern: RegExp
}

const FORBIDDEN_RULES: ForbiddenRule[] = [
  {
    label: "git commit --amend",
    pattern: /\bcommit\s+--amend\b/,
  },
  {
    label: "git push --force / -f / --force-with-lease",
    pattern: /\bpush\s+(--force\b|--force-with-lease\b|-f\b)/,
  },
  {
    label: "aws CLI",
    pattern: /\baws\b/,
  },
]

export default (async () => {
  return {
    "tool.execute.before": async (
      input: { tool: { name: string }; args: { command?: string } },
      _output: unknown,
    ) => {
      if (input.tool.name !== "bash") return
      const command = input.args.command ?? ""
      for (const rule of FORBIDDEN_RULES) {
        if (rule.pattern.test(command)) {
          throw new Error(
            `[deny-dangerous-commands] Blocked: command contains a forbidden operation (${rule.label}).`,
          )
        }
      }
    },
  }
}) satisfies Plugin
