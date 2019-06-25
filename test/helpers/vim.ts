import * as cp from "child_process";
import { attach, NeovimClient } from "neovim";
import path from "path";
import { delay } from ".";

const startVim = async () => {
  const vimrc = path.resolve(__dirname, "vimrc");
  const proc = cp.spawn("nvim", ["-u", vimrc, "-i", "NONE", "--embed"], {
    cwd: __dirname
  });
  const nvim: NeovimClient = await attach({ proc });

  nvim.uiAttach(120, 120, {}).catch(_ => {});

  return { proc, nvim };
};

const stopVim = async (nvim: NeovimClient, proc: cp.ChildProcess) => {
  await nvim.quit();
  await proc.kill("SIGKILL");
};

type WithVimTest = (nvim: NeovimClient) => void;

export const withVim = async (test: WithVimTest) => {
  const { nvim, proc } = await startVim();

  await delay(100);
  await test(nvim);
  await stopVim(nvim, proc);
};
