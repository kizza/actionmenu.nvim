import { NeovimClient } from "neovim";
import { ActionItem, ComplexItem } from ".";

export const callbackResult = async (nvim: NeovimClient) => {
  const index = await nvim.getVar("test_callback_index");
  const item = (await nvim.getVar("test_callback_item")) as ActionItem;

  return { index, item };
};

export const isComplexItem = (item: any): item is ComplexItem =>
  item.word !== undefined;
