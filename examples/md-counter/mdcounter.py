#!/usr/bin/env python3
"""
MD Counter - Markdown 字数统计工具
"""
import sys
import argparse
from dataclasses import dataclass
from typing import Optional
import re


@dataclass
class ParsedMarkdown:
    """解析后的 Markdown 数据"""
    plain_text: str
    total_lines: int
    links: list


@dataclass
class Stats:
    """统计结果"""
    chinese_chars: int
    english_words: int
    total_lines: int
    links: int


def parse_markdown(content: str) -> ParsedMarkdown:
    """
    解析 Markdown 内容

    Args:
        content: 原始 markdown 文本

    Returns:
        ParsedMarkdown 对象
    """
    # 提取链接
    link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
    links = re.findall(link_pattern, content)

    # 移除代码块
    content_no_code = re.sub(r'```.*?```', '', content, flags=re.DOTALL)
    content_no_code = re.sub(r'`[^`]+`', '', content_no_code)

    # 移除链接 URL（保留链接文本）
    plain_text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', content_no_code)

    # 移除 markdown 标记
    plain_text = re.sub(r'#+\s+', '', plain_text)  # 标题
    plain_text = re.sub(r'\*\*([^*]+)\*\*', r'\1', plain_text)  # 粗体
    plain_text = re.sub(r'\*([^*]+)\*', r'\1', plain_text)  # 斜体

    total_lines = len(content.split('\n'))

    return ParsedMarkdown(
        plain_text=plain_text,
        total_lines=total_lines,
        links=links
    )


def count_chinese(text: str) -> int:
    """统计中文字符数"""
    return sum(1 for char in text if '一' <= char <= '鿿')


def count_english_words(text: str) -> int:
    """统计英文单词数"""
    # 移除中文字符
    text_no_chinese = re.sub(r'[一-鿿]', '', text)
    # 按空白分割
    words = text_no_chinese.split()
    # 过滤纯标点
    return len([w for w in words if re.search(r'[a-zA-Z]', w)])


def count_stats(parsed: ParsedMarkdown) -> Stats:
    """
    统计各维度数据

    Args:
        parsed: ParsedMarkdown 对象

    Returns:
        Stats 对象
    """
    return Stats(
        chinese_chars=count_chinese(parsed.plain_text),
        english_words=count_english_words(parsed.plain_text),
        total_lines=parsed.total_lines,
        links=len(parsed.links)
    )


def format_output(filename: str, stats: Stats) -> str:
    """格式化输出"""
    return f"""File: {filename}
─────────────────
Chinese chars:  {stats.chinese_chars}
English words:  {stats.english_words}
Total lines:    {stats.total_lines}
Links:          {stats.links}"""


def main():
    """主入口"""
    parser = argparse.ArgumentParser(
        description='Markdown 字数统计工具'
    )
    parser.add_argument(
        'file',
        nargs='?',
        help='Markdown 文件路径（省略则读取 stdin）'
    )

    args = parser.parse_args()

    # 读取内容
    try:
        if args.file:
            with open(args.file, 'r', encoding='utf-8') as f:
                content = f.read()
            filename = args.file
        else:
            content = sys.stdin.read()
            filename = 'stdin'
    except FileNotFoundError:
        print(f"Error: File '{args.file}' not found", file=sys.stderr)
        sys.exit(1)
    except PermissionError:
        print(f"Error: Permission denied for '{args.file}'", file=sys.stderr)
        sys.exit(1)

    # 解析 + 统计
    parsed = parse_markdown(content)
    stats = count_stats(parsed)

    # 输出
    print(format_output(filename, stats))


if __name__ == '__main__':
    main()
