import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/models/new_solution_model/know_procedure_model.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_procedure_and_professional_screen.dart';
import 'package:readmore/readmore.dart';

// ignore: must_be_immutable
class KnowYourProcedureCard extends BaseActivity {
  KnowYourProcedureModel? knowYourProcedureModel;
  String? title;

  KnowYourProcedureCard(this.knowYourProcedureModel, this.title);

  @override
  _KnowYourProcedureCardState createState() => _KnowYourProcedureCardState();
}

class _KnowYourProcedureCardState extends State<KnowYourProcedureCard> {
  KnowYourProcedureModel? _knowYourProcedureModel;

  @override
  void initState() {
    _knowYourProcedureModel = widget.knowYourProcedureModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: widget.getAppBar(
            context, widget?.title ?? "Know your procedure", true) as PreferredSizeWidget?,
        body: _getBody(),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: AppConfig.verticalBlockSize * 2.2,
          horizontal: AppConfig.horizontalBlockSize * 2.8),
      child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          padding: EdgeInsets.zero,
          childAspectRatio: 0.88,
          children: _getProcedureAlteredList()),
    );
  }

  List<Widget> _getProcedureAlteredList() {
    List<Widget> list = [];
    for (int index = 0;
        index < _knowYourProcedureModel!.data!.length ?? 0 as bool;
        index++) {
      var data = _knowYourProcedureModel!.data![index];
      list.add(_proceduresCard(data.familyImage ?? "", data.familyName ?? "",
          data.details ?? "", data));
    }
    return list;
  }

  Widget _proceduresCard(
      String url, String label, String text, ProcedureData procedureData) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProcedureAndProfessional(
                    procedureData: procedureData)));
      },
      onDoubleTap: () {},
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                child:
                    CustomWidgets().getImageFromUrl(url, boxFit: BoxFit.cover),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      right: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 0.1),
                  child: Text(
                    label ?? "",
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 0.2,
                      right: AppConfig.horizontalBlockSize * 2),
                  child: IgnorePointer(
                    ignoring: true,
                    child: ReadMoreText(text ?? "",
                        textAlign: TextAlign.left,
                        trimLines: 2,
                        trimExpandedText: "Read more",
                        trimMode: TrimMode.Line,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff444444),
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
