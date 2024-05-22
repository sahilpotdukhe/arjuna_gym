import 'package:arjunagym/Screens/EditMemberPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arjunagym/Models/GymPlan.dart';
import 'package:arjunagym/Models/MemberModel.dart';
import 'package:arjunagym/Provider/MembersProvider.dart';
import 'package:arjunagym/Provider/PlanProvider.dart';
import 'package:intl/intl.dart';

class MemberListPage extends StatefulWidget {
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  @override
  void initState() {
    super.initState();
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context, listen: false);
    memberProvider.getAllMembers();
    gymPlanProvider.fetchPlans(); // Fetch plans
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Member List'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All Members'),
              Tab(text: 'Active Members'),
              Tab(text: 'Expired Members'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MemberListSection(
              filter: (member, plans) => true,
              emptyMessage: 'No members found.',
            ),
            MemberListSection(
              filter: (member, plans) => !member.isExpired(plans),
              emptyMessage: 'No active members found.',
            ),
            MemberListSection(
              filter: (member, plans) => member.isExpired(plans),
              emptyMessage: 'No expired members found.',
            ),
          ],
        ),
      ),
    );
  }
}

class MemberListSection extends StatelessWidget {
  final bool Function(Member, List<GymPlan>) filter;
  final String emptyMessage;

  const MemberListSection({
    required this.filter,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    final gymPlanProvider = Provider.of<GymPlanProvider>(context);
    final members = memberProvider.members;
    final plans = gymPlanProvider.plans;

    if (members.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final filteredMembers =
        members.where((member) => filter(member, plans)).toList();

    if (filteredMembers.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        final plan = GymPlan.findById(plans, member.planId);
        final planName = plan?.name ?? 'Unknown Plan';
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(member.photoUrl),
          ),
          title: Text(member.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mobile Number: ${member.mobileNumber}'),
              Text(
                  'Date of Birth: ${DateFormat('dd-MM-yyyy').format(member.dateOfBirth)}'),
              Text('Height: ${member.height} cm'),
              Text('Weight: ${member.weight} kg'),
              Text(
                  'Admission Date: ${DateFormat('dd-MM-yyyy').format(member.dateOfAdmission)}'),
              Text(
                  'Plan Status: ${member.isExpired(plans) ? 'Expired' : 'Active'}'),
              Text(
                  'Expiry Date: ${DateFormat('dd-MM-yyyy').format(member.expiryDate)}'),
              Text('Plan: $planName'), // Display the plan name
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditMemberPage(member: member)));
                  },
                  icon: Icon(Icons.edit))
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Deletion'),
                    content: Text(
                        'Are you sure you want to delete this member?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                try {
                  await FirebaseFirestore.instance
                      .collection('members')
                      .doc(member.id)
                      .delete();
                  await FirebaseFirestore.instance
                      .collection('recyclebin')
                      .doc(member.id)
                      .set(member.toMap());

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Member deleted successfully')),
                  );

                  memberProvider.getAllMembers();
                } catch (error) {
                  print('Error deleting member: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete member')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}
