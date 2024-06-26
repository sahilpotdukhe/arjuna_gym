import 'package:arjunagym/Widgets/ScaleUtils.dart';
import 'package:arjunagym/Widgets/UniversalVariables.dart';
import 'package:arjunagym/Screens/InvoicesScreens/ViewInvoicePage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:arjunagym/Models/GymPlanModel.dart';
import 'package:arjunagym/Models/MemberModel.dart';
import 'package:arjunagym/Provider/MemberProvider.dart';
import 'package:arjunagym/Provider/GymPlanProvider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RenewMembershipPage extends StatefulWidget {
  final MemberModel member;

  const RenewMembershipPage({required this.member});

  @override
  _RenewMembershipPageState createState() => _RenewMembershipPageState();
}

class _RenewMembershipPageState extends State<RenewMembershipPage> {
  late TextEditingController _renewalDateController;
  late TextEditingController _cashAmountController;
  GymPlanModel? _selectedPlan;
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Cash', 'Online'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _renewalDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(widget.member.renewalDate));
    _cashAmountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final plans = Provider.of<GymPlanProvider>(context).plans;
    ScaleUtils.init(context);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: UniversalVariables.appThemeColor,
          title: Text(
            'Renew Membership',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Name: ${widget.member.name}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _renewalDateController,
                decoration: InputDecoration(
                  hintText: 'Renewal Date',
                  labelText: 'Renewal Date',
                  labelStyle:
                      TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                  floatingLabelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18 * ScaleUtils.scaleFactor,
                      color: HexColor('3957ED')),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.date_range, color: HexColor('3957ED')),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('3957ED'), width: 2),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.member.renewalDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _renewalDateController.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<GymPlanModel>(
                value: _selectedPlan,
                decoration: InputDecoration(
                  hintText: 'Select new Plan',
                  labelText: 'Plan',
                  labelStyle:
                      TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                  floatingLabelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18 * ScaleUtils.scaleFactor,
                      color: HexColor('3957ED')),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('3957ED'), width: 2),
                  ),
                  suffixIcon: Icon(Icons.height, color: HexColor('3957ED')),
                ),
                items: plans.map((GymPlanModel plan) {
                  return DropdownMenuItem<GymPlanModel>(
                    value: plan,
                    child: Text(plan.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a plan';
                  }
                  return null;
                },
                onChanged: (GymPlanModel? newPlan) {
                  setState(() {
                    _selectedPlan = newPlan;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  hintText: 'Select Payment Mode',
                  labelText: 'Payment Mode',
                  labelStyle:
                      TextStyle(fontSize: 16.0 * ScaleUtils.scaleFactor),
                  floatingLabelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18 * ScaleUtils.scaleFactor,
                      color: HexColor('3957ED')),
                  border: OutlineInputBorder(),
                  suffixIcon:
                      Icon(Icons.credit_card, color: HexColor('3957ED')),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: HexColor('3957ED'), width: 2)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: HexColor('3957ED'), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select payment mode';
                  }
                  return null;
                },
                items: _paymentMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newMethod) {
                  setState(() {
                    _selectedPaymentMethod = newMethod;
                  });
                },
              ),
              if (_selectedPaymentMethod == 'Online')
                Column(
                  children: [
                    SizedBox(height: 10),
                    Image.asset(
                      'assets/QRcode.jpg',
                      // Replace with your QR code image URL
                      height: 350,
                      width: 350,
                    ),
                    SizedBox(height: 10),
                    Text('Scan the QR code to pay online'),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _renewMembership,
                child: Text('Renew Membership'),
              ),
            ],
          ),
        ),
      ),
      if (_isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ]);
  }

  Future<void> _renewMembership() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a plan')),
      );
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newDateOfRenewal =
          DateFormat('dd-MM-yyyy').parse(_renewalDateController.text);
      final renewedMember =
          widget.member.renewMembership(_selectedPlan!, newDateOfRenewal);
      await Provider.of<MemberProvider>(context, listen: false)
          .updateMember(renewedMember);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Membership renewed successfully')),
      );
      AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        headerAnimationLoop: true,
        dialogType: DialogType.success,
        showCloseIcon: true,
        //autoHide: Duration(seconds: 6),
        title: 'Renewed!',
        desc:
            'You have successfully Renewed Membership.\n Please wait you will be redirected to the MembersList Screen.',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
        onDismissCallback: (type) {
          debugPrint('Dialog Dissmiss from callback $type');
        },
      ).show();
      await Future.delayed(Duration(seconds: 4));
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewInvoicePage(member: renewedMember,)));
    } catch (error) {
      print('Error renewing membership: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to renew membership')),
      );
    }
  }
}
