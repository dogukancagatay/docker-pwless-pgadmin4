import os
import re
from playwright.sync_api import Playwright, sync_playwright, expect


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    # Open new page and go to our URL
    page = context.new_page()
    url = "http://localhost:15432"
    page.goto(url)

    expect(page.get_by_text("Servers", exact=True)).to_be_visible()
    page.locator("i").first.click()
    expect(page.get_by_text("postgres", exact=True)).to_be_visible()
    expect(page.get_by_text("Databases")).to_be_visible()

    # Databases
    page.locator("div:nth-child(3) > div > .file-entry > .directory-toggle").click()
    expect(page.get_by_text("my_db")).to_be_visible()
    expect(page.get_by_text("postgres").nth(1)).to_be_visible()

    # my_db tree
    page.locator("div:nth-child(4) > div > .file-entry > .directory-toggle").click()
    page.get_by_role("button", name="Query Tool", exact=True)
    expect(page.get_by_text("my_db/my_user@postgres")).to_be_visible()
    expect(
        page.locator("iframe").content_frame.get_by_role(
            "button", name="my_db/my_user@postgres"
        )
    ).to_be_visible()
    expect(
        page.get_by_title("Query Tool - my_db/my_user@").get_by_label("Close")
    ).to_be_visible()
    page.get_by_title("Query Tool - my_db/my_user@").get_by_label("Close").click()

    # postgres tree
    page.locator("div:nth-child(14) > div > .file-entry > .directory-toggle").click()
    page.get_by_role("button", name="Query Tool", exact=True)
    expect(page.get_by_text("postgres/my_user@postgres")).to_be_visible()
    expect(
        page.locator("iframe").content_frame.get_by_role(
            "button", name="postgres/my_user@postgres"
        )
    ).to_be_visible()
    expect(
        page.get_by_title("Query Tool - postgres/my_user").get_by_label("Close")
    ).to_be_visible()
    page.get_by_title("Query Tool - postgres/my_user").get_by_label("Close").click()


with sync_playwright() as playwright:
    run(playwright)
