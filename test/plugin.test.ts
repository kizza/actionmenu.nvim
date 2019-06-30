import assert from "assert";
import { withVim } from "./helpers/vim";
import { callbackResult, isComplexItem } from "./helpers/callback";
import { ENTER, ESC, openActionMenu } from "./helpers";

describe("actionmenu", () => {
  it("loads the test vimrc", () =>
    withVim(async nvim => {
      const loaded = (await nvim.getVar("test_vimrc_loaded")) as boolean;

      assert.equal(loaded, true);
    }));

  it("can set and read a line", () =>
    withVim(async nvim => {
      await nvim.setLine("Foo");

      const line = await nvim.getLine();

      assert.equal(line, "Foo");
    }));

  it("doesn't open the pum initially", () =>
    withVim(async nvim => {
      const visible = await nvim.call("pumvisible");

      assert.equal(visible, 0);
    }));

  it("opens the pum when called", () =>
    withVim(async nvim => {
      await openActionMenu(nvim, ["One", "Two", "Three"]);

      const visible = await nvim.call("pumvisible");

      assert.equal(visible, 1);
    }));

  describe("navigating the menu", () => {
    it("moves up and down with j and k", () =>
      withVim(async nvim => {
        await openActionMenu(nvim, ["One", "Two", "Three"]);

        await nvim.call("feedkeys", [`jjk${ENTER}`]);

        const { index, item } = await callbackResult(nvim);

        assert.equal(index, 1);
        assert.equal(item, "Two");
      }));
  });

  describe("opening and closing the menu", () => {
    it("starts with a single buffer", () =>
      withVim(async nvim => {
        const buffers = await nvim.call("nvim_list_bufs");

        assert.equal(buffers.toString(), [1].toString());
      }));

    it("it focuses a second buffer when the menu is opened", () =>
      withVim(async nvim => {
        await openActionMenu(nvim, ["One", "Two", "Three"]);

        const buffers = await nvim.call("nvim_list_bufs");
        const currentBuffer = await nvim.call("nvim_get_current_buf");

        assert.equal(buffers.toString(), [1, 2].toString());
        assert.equal(currentBuffer, 2);
      }));

    it("focuses the original buffer when the menu is closed", () =>
      withVim(async nvim => {
        const originalBuffer = await nvim.call("nvim_get_current_buf");

        await openActionMenu(nvim, ["One", "Two", "Three"]);
        const menuBuffer = await nvim.call("nvim_get_current_buf");

        await nvim.call("feedkeys", [ESC]);
        const currentBuffer = await nvim.call("nvim_get_current_buf");

        assert.equal(currentBuffer, originalBuffer);
        assert.notEqual(originalBuffer, menuBuffer);
      }));
  });

  describe("custom icon", () => {
    it("can use a custom character as an icon", () =>
      withVim(async nvim => {
        const icon = {
          character: "!",
          foreground: "red"
        };

        await nvim.command(
          `execute('call actionmenu#open(["One", "Two", "Three"], "TestCallback", { "icon": ${JSON.stringify(
            icon
          )} })')`
        );

        const line = await nvim.getLine();
        assert.equal(line, "One!");
      }));
  });

  describe("callback", () => {
    describe("when an item is not selected", () => {
      it("returns -1 index with null", () =>
        withVim(async nvim => {
          await nvim.command(
            `execute("call actionmenu#open(['One', 'Two', 'Three'], 'TestCallback')")`
          );

          await nvim.call("feedkeys", [ESC]);
          const { index, item } = await callbackResult(nvim);

          assert.equal(index, -1);
          assert.equal(item, 0);
        }));
    });

    describe("when an item is selected", () => {
      it("returns the selected index and item", () =>
        withVim(async nvim => {
          await openActionMenu(nvim, ["One", "Two", "Three"]);

          await nvim.call("feedkeys", [ENTER]);

          const { index, item } = await callbackResult(nvim);

          assert.equal(index, 0);
          assert.equal(item, "One");
        }));

      it("returns the selected index and complex item", () =>
        withVim(async nvim => {
          await openActionMenu(nvim, [{ word: "One", user_data: "Foo" }]);

          await nvim.call("feedkeys", [ENTER]);

          const { index, item } = await callbackResult(nvim);

          assert.equal(index, 0);
          assert.equal(isComplexItem(item), true);
          if (isComplexItem(item)) {
            assert.equal(item.word, "One");
            assert.equal(item.user_data, "Foo");
          }
        }));

      it("invokes the callback once", async () =>
        withVim(async nvim => {
          const buffer = nvim.buffer;

          const selectAnItem = async () => {
            await openActionMenu(nvim, ["One"], '"TestPrintCallback"');
            await nvim.call("feedkeys", [ENTER]);
          };

          await selectAnItem();
          await selectAnItem();
          await selectAnItem();

          const lines = await buffer.getLines();
          assert.equal(lines.toString(), ["OneOneOne"].toString());
        }));
    });
  });
});
