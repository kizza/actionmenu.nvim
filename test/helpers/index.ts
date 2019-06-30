import { NeovimClient } from "neovim";

export interface ComplexItem {
  word: string;
  abbr?: string;
  user_data?: any;
}

export type ActionItem = string | ComplexItem;

export const ENTER = String.fromCharCode(13);

export const ESC = String.fromCharCode(27);

export const openActionMenu = async (
  nvim: NeovimClient,
  items: ActionItem[],
  callback = '"TestCallback"'
) => {
  await nvim.command(
    `execute('call actionmenu#open(${JSON.stringify(items)}, ${callback})')`
  );
};

export const delay = (milliseconds: number) =>
  new Promise((resolve, _) => {
    setTimeout(() => resolve(), milliseconds);
  });
