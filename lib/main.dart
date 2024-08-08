import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://lopmqyysroszcogxruul.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxvcG1xeXlzcm9zemNvZ3hydXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIwMTI1MjQsImV4cCI6MjAzNzU4ODUyNH0.0ijMWVV6SF0cafOJ0P9_SyziUaTgPH1TSdHPgJU5EaI';
final supabase = Supabase.instance.client;
void main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Assesment WrenEV',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: MyHomePage(
        toggleTheme: _toggleTheme,
        isDarkTheme: _isDarkTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final void Function() toggleTheme;
  final bool isDarkTheme;

  MyHomePage({required this.toggleTheme, required this.isDarkTheme});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPanelOpen = true;

  int totalEmployees = 0;
  int jobApplicants = 0;
  int newEmployees = 0;
  int resignedEmployees = 0;
  String connectionStatus = 'Checking connection...';
  int onboarding = 0;
  int offboarding = 0;
  int others = 0;
  int touchedIndex = -1;

  List<int> team1Performance = [
    40000,
    45000,
    42000,
    47000,
    50000,
    49000,
    52000,
    50000
  ];
  List<int> team2Performance = [
    45000,
    43000,
    46000,
    49000,
    45000,
    50000,
    51000,
    49000
  ];
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug'
  ];

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
    });
  }

  Future<void> fetchdata() async {
    try {
      final performanceTableResponse = await Supabase.instance.client
          .from('performance_table')
          .select()
          .order('month');

      final performanceData = performanceTableResponse as List<dynamic>;

      if (performanceData.isEmpty) {
        throw Exception('No data found in performance_table');
      }

      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];

      List<int> team1Performance = [];
      List<int> team2Performance = [];

      for (String month in months) {
        final team1Item = performanceData.firstWhere(
          (d) => d['team'] == 'Project Team' && d['month'] == month,
          orElse: () => {'performance': 0},
        );
        team1Performance.add(team1Item['performance']);

        final team2Item = performanceData.firstWhere(
          (d) => d['team'] == 'Product Team' && d['month'] == month,
          orElse: () => {'performance': 0},
        );
        team2Performance.add(team2Item['performance']);
      }

      final totalResponse =
          await Supabase.instance.client.from('employees').select('id');

      final jobApplicantsResponse =
          await Supabase.instance.client.from('job_applicants').select('id');

      final newEmployeesResponse = await Supabase.instance.client
          .from('employees')
          .select('id')
          .gte('joined', '2024-07-01');

      final resignedEmployeesResponse = await Supabase.instance.client
          .from('employees')
          .select('id')
          .eq('available', false);

      setState(() {
        jobApplicants = jobApplicantsResponse.length * 100;
        newEmployees = newEmployeesResponse.length * 1000;
        resignedEmployees = resignedEmployeesResponse.length * 1000;
        totalEmployees = (totalResponse.length * 1000) - resignedEmployees;
        onboarding = newEmployees;
        offboarding = resignedEmployees;
        others = totalEmployees;
        connectionStatus = 'Connection successful!';
        this.team1Performance = team1Performance;
        this.team2Performance = team2Performance;
      });
    } catch (error) {
      print(error);
      setState(() {
        connectionStatus = 'Error: $error';
      });
    }
  }

  void _onButtonPressed() {
    print('Button pressed');
  }

  Widget _buildNavBarButton(String text) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextButton(
          onPressed: () {
            // Handle button press
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: <Widget>[
          // Side Panel
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _isPanelOpen ? 0 : -320,
            top: 0,
            bottom: 0,
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: widget.isDarkTheme ? Colors.black : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 100,
                    color: widget.isDarkTheme ? Colors.black : Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/starIcon1.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Humanline',
                              style: TextStyle(
                                color: widget.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.keyboard_double_arrow_left,
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black),
                          onPressed: _togglePanel,
                        ),
                      ],
                    ),
                  ),
                  // Pressable button with green background, left-aligned text, and right icon with padding
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 75,
                      child: ElevatedButton(
                        onPressed: _onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 51, 177, 55),
                          padding: EdgeInsets.zero,
                          textStyle: TextStyle(
                            fontSize: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Icon(
                                Icons.now_widgets_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Add expandable options
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        SizedBox(height: 10),
                        ExpansionTile(
                          title: Text(
                            'Employees',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.people_outline_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Checklist',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.checklist_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Time Off',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.timer_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Attendance',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Payroll',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.card_giftcard,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Performance',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.bar_chart_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        ExpansionTile(
                          title: Text(
                            'Recruitment',
                            style: TextStyle(
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: Icon(
                            Icons.work_outline_outlined,
                            size: 30,
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Text('Option 1'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: Text('Option 2'),
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 110),
                        ListTile(
                          title: Stack(
                            children: [
                              Text(
                                'Help Center',
                                style: TextStyle(
                                  color: widget.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '8', // The number of unread messages
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            12, // Adjust font size as needed
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          leading: Icon(
                            Icons.help_outline,
                            size: 30,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            // Add your onTap code here
                          },
                        ),
                        SizedBox(height: 0),
                        ListTile(
                          title: Text(
                            'Setting',
                            style: TextStyle(
                                color: widget.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: Icon(Icons.settings_outlined,
                              size: 30, color: Colors.grey),
                          onTap: () {
                            // Add your onTap code here
                          },
                        ),
                        SizedBox(height: 20), // Add spacing before the switch
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomSwitch(
                                value: widget.isDarkTheme,
                                onChanged: (bool value) {
                                  widget.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content and Top Navigation Bar
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: _isPanelOpen ? 320 : 0),
            child: Column(
              children: [
                // Top Navigation Bar
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: widget.isDarkTheme ? Colors.black : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Visibility(
                        visible: !_isPanelOpen,
                        child: IconButton(
                          icon: Icon(Icons.menu,
                              color: widget.isDarkTheme
                                  ? Colors.white
                                  : Colors.black),
                          onPressed: _togglePanel,
                        ),
                      ),
                      SizedBox(width: 16), // Add some spacing
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 600,
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search anything...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (text) {
                                    // Handle search logic here
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle button press
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list_alt,
                                        color: Colors
                                            .black), // Replace with your icon
                                    SizedBox(width: 4),
                                    Text(
                                      'F',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Add the buttons here
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildNavBarButton('Documents'),
                          SizedBox(width: 30),
                          _buildNavBarButton('News'),
                          SizedBox(width: 30),
                          _buildNavBarButton('Payship'),
                          SizedBox(width: 30),
                          _buildNavBarButton('Report'),
                        ],
                      ),
                      Spacer(), // Push the icons to the right
                      IconButton(
                        icon: Icon(
                          Icons.mail_outline,
                          color:
                              widget.isDarkTheme ? Colors.white : Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 15),
                      IconButton(
                        icon: Icon(
                          Icons.chat_outlined,
                          color:
                              widget.isDarkTheme ? Colors.white : Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      SizedBox(width: 15),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        child: Text('P'),
                      ),
                      SizedBox(width: 30), // Add some spacing
                    ],
                  ),
                ),
                // Main Content, need to add the container that has the data and the chart from the other project
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 16, 5, 0),
                    width: 1400,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(16, 16, 3, 16),
                              width: 600,
                              height: 400,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF8F8F8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                      Icons
                                                          .people_outline_outlined,
                                                      color: Colors.black,
                                                      size: 20),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$totalEmployees',
                                                      style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF8F8F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .trending_up_outlined,
                                                              size: 16,
                                                              color:
                                                                  Colors.green),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '+25.5%',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  'Total Employees',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.5),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF8F8F8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                      Icons.person_add_alt_1,
                                                      color: Colors.black,
                                                      size: 20),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$jobApplicants',
                                                      style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF8F8F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .trending_up_outlined,
                                                              size: 16,
                                                              color:
                                                                  Colors.green),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '+4.10%',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  'Job Applicants',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1, color: Colors.grey),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF8F8F8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$newEmployees',
                                                      style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF8F8F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .trending_up_outlined,
                                                              size: 16,
                                                              color:
                                                                  Colors.green),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '+5.1%',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  'New Employees',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.5),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF8F8F8),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons
                                                        .person_remove_outlined,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '$resignedEmployees',
                                                      style: TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF8F8F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .trending_down_outlined,
                                                              size: 16,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            '-2.3%',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),
                                                Text(
                                                  'Resigned Employees',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          //   child: Align(
                          //alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(1, 1, 1, 1),
                            padding: EdgeInsets.fromLTRB(
                                1, 1, 16, 1), // Adjusted bottom padding
                            child: TeamPerformanceChart(
                              team1Performance: team1Performance,
                              team2Performance: team2Performance,
                              months: months,
                            ),
                          ),
                          //),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: SizedBox(
                        width: double
                            .infinity, // Ensures it takes full width of its parent
                        height: 350, // Set the fixed height you want
                        child: Container(
                          margin: EdgeInsets.fromLTRB(50, 10, 16, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: EmployeeTable(),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 50, 16),
                        width: 500,
                        height: 330,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Employee',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Ensure the row only takes as much space as needed
                                    children: [
                                      Text(
                                        'All time',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                          width: 2), // Adjust to reduce space
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_drop_down_outlined),
                                        onPressed: () {
                                          // Handle button press
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 0),
                            //Container(width: 300,height: 200,),
                            SizedBox(
                              width: 300,
                              height: 200,
                              child: Stack(
                                children: [
                                  PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      sections: showingSections(),
                                      centerSpaceRadius: 60,
                                      sectionsSpace: 8,
                                      startDegreeOffset: 270,
                                      centerSpaceColor: Colors.grey[200],
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$totalEmployees',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Total Emp.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(39, 162, 115, 1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Others',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '$totalEmployees',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(255, 208, 35, 1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Onboarding',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '$onboarding',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(47, 120, 238, 1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Offboarding',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '$offboarding',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 18.0 : 16.0;
      final double radius = isTouched ? 30.0 : 20.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color.fromRGBO(39, 162, 115, 1),
            value: others.toDouble(),
            showTitle: false,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Color.fromRGBO(255, 208, 35, 1),
            value: onboarding.toDouble(),
            showTitle: false,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Color.fromRGBO(47, 120, 238, 1),
            value: offboarding.toDouble(),
            showTitle: false,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Exception('Invalid index');
      }
    });
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color.fromARGB(
              255, 179, 179, 179), // Consistent grey background
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 40, // Match the height of the parent container
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                margin: EdgeInsets.symmetric(
                    horizontal: 4.0), // Add padding inside the button
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: value ? Colors.black : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    value ? 'Dark' : 'Light',
                    style: TextStyle(
                      color: value ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamPerformanceChart extends StatelessWidget {
  final List<int> team1Performance;
  final List<int> team2Performance;
  final List<String> months;

  const TeamPerformanceChart({
    super.key,
    required this.team1Performance,
    required this.team2Performance,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Allow the chart to take full width
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Aligns children to the start (left)
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Performance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Define action for the button here
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: BorderSide(color: Colors.grey, width: 1),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last 8 months',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.calendar_today, size: 16),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10), // Space between label and chart
          // Add legend
          //EmployeeTable(),
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Project Team',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Product Team',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            margin: EdgeInsets.all(5),
            width: double.infinity,
            height: 260, // Adjusted height of the chart container
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: team1Performance
                        .asMap()
                        .entries
                        .map(
                            (e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    color: Colors.green,
                    isCurved: true,
                    curveSmoothness: 0.5, // Adjust smoothness here
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: team2Performance
                        .asMap()
                        .entries
                        .map(
                            (e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    color: Colors.yellow,
                    isCurved: true,
                    curveSmoothness: 0.5, // Adjust smoothness here
                    dotData: FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40, // Increase reserved size if needed
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < months.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              months[index],
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40, // Space for titles
                      interval: 10000, // Set interval to 10,000
                      getTitlesWidget: (value, meta) {
                        final intValue = value.toInt();
                        if (intValue == 20000) {
                          return const SizedBox.shrink(); // Hide 20k
                        }
                        String title = '${intValue ~/ 1000}k'; // Format as k
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            title,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: 1.0,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 1,
                    );
                  },
                  drawHorizontalLine: false,
                ),
                minY: 20000, // Set minimum value for y-axis
                maxY: 60000, // Set maximum value for y-axis
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Employee {
  final String name;
  final String jobTitle;
  final String lineManager;
  final String department;
  final String office;
  final String email;

  Employee({
    required this.name,
    required this.jobTitle,
    required this.lineManager,
    required this.department,
    required this.office,
    required this.email,
  });
}

class EmployeeTable extends StatefulWidget {
  @override
  _EmployeeTableState createState() => _EmployeeTableState();
}

class _EmployeeTableState extends State<EmployeeTable> {
  List<Employee> employees = [
    Employee(
      name: 'Adam Jabado',
      jobTitle: 'UI UX Designer',
      lineManager: '@MarcKaterji',
      department: 'Product Team',
      office: 'Unpixel Office',
      email: 'Adam@unpixel.com',
    ),
    Employee(
      name: 'Marc Katerji',
      jobTitle: 'Graphic Designer',
      lineManager: '@Pristiacandra',
      department: 'Project Team',
      office: 'Unpixel Office',
      email: 'Marc@unpixel.com',
    ),
  ];

  String officeFilter = 'All Offices';
  String jobTitleFilter = 'All Job Titles';
  String statusFilter = 'All Status';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Employee> filteredEmployees = employees.where((employee) {
      return (officeFilter == 'All Offices' ||
              employee.office == officeFilter) &&
          (jobTitleFilter == 'All Job Titles' ||
              employee.jobTitle == jobTitleFilter) &&
          (employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              employee.jobTitle
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()));
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        // Remove fixed width
        width: double.infinity, // Ensure it takes full width of its parent
        height: 350, // Keep fixed height
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Employees',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 450,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search employee',
                      prefixIcon: Icon(Icons.search),
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(4, 4, 20, 4),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Offices',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: officeFilter,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All Offices',
                              child: Text(
                                ' ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Unpixel Office',
                              child: Text(
                                'Unpixel Office',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              officeFilter = value!;
                            });
                          },
                          underline: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 4, 20, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Job Title',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: jobTitleFilter,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All Job Titles',
                              child: Text(
                                ' ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'UI UX Designer',
                              child: Text(
                                'UI UX Designer',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Graphic Designer',
                              child: Text(
                                'Graphic Designer',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              jobTitleFilter = value!;
                            });
                          },
                          underline: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 4, 4, 4),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: statusFilter,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'All Status',
                              child: Text(
                                ' ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Active',
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Inactive',
                              child: Text(
                                'Inactive',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              statusFilter = value!;
                            });
                          },
                          underline: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          Colors.grey[200]), // Set header row background color
                      columns: [
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                'Emp. Name',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold), // Make text smaller
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.unfold_more,
                                  size: 15), // Adjust icon size
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                'Job Title',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold), // Make text smaller
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.unfold_more,
                                  size: 15), // Adjust icon size
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                'Manager',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold), // Make text smaller
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.unfold_more,
                                  size: 15), // Adjust icon size
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                'Department',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold), // Make text smaller
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.unfold_more,
                                  size: 15), // Adjust icon size
                            ],
                          ),
                        ),
                        DataColumn(
                          label: Row(
                            children: [
                              Text(
                                'Office',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold), // Make text smaller
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.unfold_more,
                                  size: 15), // Adjust icon size
                            ],
                          ),
                        ),
                      ],
                      rows: filteredEmployees
                          .map(
                            (employee) => DataRow(
                              cells: [
                                DataCell(Text(employee.name)),
                                DataCell(Text(employee.jobTitle)),
                                DataCell(Text(employee.lineManager)),
                                DataCell(Text(employee.department)),
                                DataCell(Text(employee.office)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
