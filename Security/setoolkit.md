# Setoolkit

I can convert that page into GitBook-optimized Markdown, but I don’t have browsing access to fetch the page content directly. Please either:

* Paste the page’s content (HTML or Markdown) here, or
* Paste the raw text you want converted, or
* Grant the page content by copying the relevant sections (including code blocks and images) into the chat.

Before I transform it, here’s what I will do to produce GitBook-ready Markdown (I’ll follow these rules exactly):

* Keep the original structure and meaning; I won’t add new content or change any URLs (query parameters will be preserved).
* Remove navigation elements (e.g., “On this page”, logos, skip links).
* Convert long numbered lists of multi-paragraph steps into a stepper block (removing the numeric prefix from each step title).
* Convert package-manager code samples (npm / yarn / pnpm) into a tabs block (one tab per package manager).
*   Convert FAQs into expandable blocks (

    ).
* Preserve images; if any image is embedded as base64 I will leave it untouched.
* Use GitBook advanced blocks where appropriate: tabs, stepper, hint, expandable, columns, cards, code block titles, etc.

If you paste the page, I’ll return a complete GitBook-compatible Markdown file (with Liquid blocks) optimized per the rules above.

Would you like to paste the page content now? If you prefer, tell me which sections to include (whole page or only specific headings).
