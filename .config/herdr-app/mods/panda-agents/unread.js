export async function markUnread(terminal, hc) {
  // Read the latest turn when clicked, including for a remote agent.
  const result = await hc(["get", terminal, "--json"]);
  if (result.code !== 0) throw new Error(result.stderr || result.stdout || "Cannot read the agent's current turn.");
  const turn = JSON.parse(result.stdout).turn;
  if (turn === 0) return false;
  if (!Number.isSafeInteger(turn) || turn < 0) throw new Error("Cannot read the agent's current turn.");
  const label = await hc(["label", terminal, `herdr.seen=${turn - 1}`]);
  if (label.code !== 0) throw new Error(label.stderr || label.stdout || "Cannot mark the agent as unread.");
  return true;
}
