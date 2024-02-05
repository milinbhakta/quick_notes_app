import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<RssItem> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final response =
        await http.get(Uri.parse('https://www.firstpost.com/rss/world.xml'));
    final rssFeed = RssFeed.parse(response.body);

    setState(() {
      _newsItems = rssFeed.items ?? [];
    });
  }

  void _openNews(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final item = _newsItems[index];
          return Card(
            child: ListTile(
              leading: item.media != null
                  ? Image.network(
                      item.media!.contents![0].url ?? '',
                      fit: BoxFit.cover,
                    )
                  : null,
              title: Text(item.title ?? ''),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.description}\n',
                      style: DefaultTextStyle.of(context).style,
                    ),
                    TextSpan(
                      text: item.author ?? '',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              onTap: () => _openNews(item.link!),
            ),
          );
        },
      ),
    );
  }
}
