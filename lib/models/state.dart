
class States {

  String stateId, state;
  States({this.stateId, this.state});

  States.fromJson(Map<String, dynamic> json) :
    stateId = json['state_id'],
    state = json['state'];


}