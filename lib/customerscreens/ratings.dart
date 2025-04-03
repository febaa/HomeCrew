import 'package:flutter/material.dart';

void main() {
  runApp(RatingsPage());
}

class RatingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Ratings'),
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'You currently have no ratings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.star, color: Colors.yellow, size: 30),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Introducing customer ratings'),
                _buildSectionText(
                  'Just like you rate UC professionals for the overall quality of the service, they also rate you on a scale of 1 to 5. Your aggregate rating is calculated after you have received ratings in at least 3 services.',
                ),
                SizedBox(height: 20),
                _buildSectionTitle('How can I be a 5-star customer?'),
                _buildSectionText(
                  'Did you know that nearly 80% of UC customers are 5-star rated? If you also want that coveted rating, here are a few kind gestures.',
                ),
                SizedBox(height: 10),
                _buildEmojiSection('🤝', 'Empathise', 'Show them you care by offering water, it’ll help raise their spirit and energy levels.'),
                _buildEmojiSection('❤️', 'Support', 'Provide access to the washroom (if required); they might have been on the go for a while!'),
                _buildEmojiSection('💬', 'Respect', 'Treat professionals the way you’d expect to be treated.'),
                SizedBox(height: 20),
                _buildSectionTitle('How is customer rating calculated?'),
                _buildSectionText(
                  'Your aggregate rating is a simple average of all the ratings you’ve received from UC professionals in the past. These individual ratings are anonymous, and so won’t be visible to you or the professional.',
                ),
                SizedBox(height: 20), // Extra space at bottom for better scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  Widget _buildEmojiSection(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
