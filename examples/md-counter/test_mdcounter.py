"""
单元测试 for mdcounter
"""
import sys
import os
import pytest
from io import StringIO

# 添加父目录到 sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from mdcounter import (
    parse_markdown,
    count_chinese,
    count_english_words,
    count_stats,
    format_output,
    Stats
)


class TestParsing:
    """解析模块测试"""

    def test_parse_plain_text(self):
        """纯文本解析"""
        content = "Hello world"
        result = parse_markdown(content)
        assert "Hello world" in result.plain_text
        assert result.total_lines == 1
        assert len(result.links) == 0

    def test_parse_with_code_block(self):
        """代码块应被移除"""
        content = "Text\n```python\ncode\n```\nMore text"
        result = parse_markdown(content)
        assert "code" not in result.plain_text
        assert "Text" in result.plain_text
        assert "More text" in result.plain_text

    def test_parse_with_inline_code(self):
        """行内代码应被移除"""
        content = "Use `variable` here"
        result = parse_markdown(content)
        assert "variable" not in result.plain_text
        assert "Use" in result.plain_text

    def test_parse_links(self):
        """链接应被提取"""
        content = "Check [this link](http://example.com)"
        result = parse_markdown(content)
        assert len(result.links) == 1
        assert result.links[0][1] == "http://example.com"
        # 链接文本保留在 plain_text 中
        assert "this link" in result.plain_text


class TestChinese:
    """中文统计测试"""

    def test_count_pure_chinese(self):
        """纯中文"""
        assert count_chinese("你好世界") == 4

    def test_count_chinese_with_english(self):
        """中英混合"""
        assert count_chinese("你好world") == 2

    def test_count_no_chinese(self):
        """无中文"""
        assert count_chinese("Hello world") == 0

    def test_count_chinese_with_punctuation(self):
        """含标点（中文标点不计入）"""
        text = "你好，世界！"
        # Unicode 范围 U+4E00-U+9FFF 不含中文标点
        assert count_chinese(text) == 4


class TestEnglishWords:
    """英文单词统计测试"""

    def test_count_pure_english(self):
        """纯英文"""
        assert count_english_words("Hello world test") == 3

    def test_count_english_with_chinese(self):
        """中英混合"""
        assert count_english_words("你好world test") == 2

    def test_count_no_english(self):
        """无英文"""
        assert count_english_words("你好世界") == 0

    def test_filter_pure_punctuation(self):
        """过滤纯标点"""
        assert count_english_words("Hello , world !") == 2


class TestStats:
    """统计功能测试"""

    def test_count_stats_comprehensive(self):
        """综合统计"""
        content = "# Title\n你好world\n[link](url)"
        parsed = parse_markdown(content)
        stats = count_stats(parsed)

        assert stats.chinese_chars == 2
        assert stats.english_words >= 2  # "Title" + "world"
        assert stats.total_lines == 3
        assert stats.links == 1


class TestFormatOutput:
    """输出格式测试"""

    def test_format_output(self):
        """输出格式验证"""
        stats = Stats(
            chinese_chars=10,
            english_words=20,
            total_lines=30,
            links=5
        )
        output = format_output("test.md", stats)

        assert "test.md" in output
        assert "10" in output
        assert "20" in output
        assert "30" in output
        assert "5" in output


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
