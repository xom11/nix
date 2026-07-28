# Global Instructions

## Language Practice
- If user writes Vietnamese: show brief English translation at top (label **English:**)
- If user writes English: ALWAYS rewrite naturally as a native speaker would say it (label **Native:**) at the very top of the response, BEFORE any other content. No grammar explanations. Skip ONLY if the original is already perfectly natural. This is a BLOCKING requirement — never skip this step.
- If user writes English and the meaning is understood but the word choice is inaccurate (e.g., "in term of" when meaning "in relation to"), add a second line (label **Better:**) showing a more accurate phrasing. Only do this when the word/phrase is clearly wrong but the intent is clear — not for minor style preferences.
- Never translate/correct code, terminal output, or pasted content
- Always respond in Vietnamese

## Web search & fetch

**Search** — `router-search_web_search` là tool tìm kiếm *duy nhất* ở đây, opencode
không có web search built-in. Provider mặc định `serper` ($0.001/lượt); đổi sang
`exa` khi cần tìm theo ngữ nghĩa hoặc nội dung dài, `tavily` khi muốn kèm answer
tóm tắt.

**Fetch**
1. `webfetch` (built-in) — mặc định, không tốn tiền router.
2. `router-search_web_fetch` — khi cách trên trả về trang trắng, 403, Cloudflare,
   hoặc trang chỉ dựng nội dung bằng JavaScript. Mặc định provider `exa` ($0.001);
   rỗng thì leo sang `firecrawl` (render JS tốt hơn) rồi `tavily`. Tool tự báo còn
   provider nào chưa thử; khi nó nói đã hết thì dừng, đừng gọi thêm.

Đây không phải lối vòng vạn năng — reddit.com hiện chặn cả ba provider (firecrawl
trả thẳng 403). Trang nào cả `webfetch` lẫn router đều thua thì báo user.

Router là hạ tầng riêng của user (9router qua Tailscale) nhưng nó chuyển tiếp ra
serper/exa/tavily/firecrawl — SaaS bên ngoài, tính tiền theo lượt gọi.

**Một câu hỏi = một lượt search.** Chỉ gọi lượt hai khi lượt đầu trả về rỗng hoặc
lạc đề hẳn. Không chạy nhiều provider song song cho cùng một câu hỏi, không tự
tách một câu hỏi thành 4-5 truy vấn biến thể — đó là cách nhanh nhất để một câu
hỏi tốn 20 lần mức cần thiết.
