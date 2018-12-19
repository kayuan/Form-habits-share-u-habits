//
//  PromissDetailViewController.swift
//  HabitPromiss
//
//  Created by 배지호 on 2018. 5. 28..
//  Copyright © 2018년 주호박. All rights reserved.
//

import UIKit

class PromissDetailViewController: BaseViewController {
  
  //MARK: - Property
  // IBOutlet Hook up
  @IBOutlet var tap: UITapGestureRecognizer!
  @IBOutlet weak var goalTitle: UILabel!// 목표 제목
  @IBOutlet weak var goalDetailTextField: UITextField!
  
  @IBOutlet weak var startTitle: UILabel!
  @IBOutlet weak var startTextField: UITextField!
  
  @IBOutlet weak var endTitle: UILabel!
  @IBOutlet weak var endTextField: UITextField!
  
  @IBOutlet weak var scheduleTitle: UILabel!
  @IBOutlet weak var scheduleDay: UILabel!
  @IBOutlet weak var scheduleDayDetail: UILabel!
  
  @IBOutlet weak var alarmTitle: UILabel!
  @IBOutlet weak var alarmTextField: UITextField!
  
  // container View Property
  var iconVC: IconCollectionViewController?
  
  //MARK: - View UI 로직
    // 클로져로 View UI에 대한 것들을 구성하는것이 유지보수에 과연,.?
  var picker: UIDatePicker = {
    let picker = UIDatePicker()
    let today = Date()
    // 이전일은 시작일로 작성 되지 않도록 지정.
    picker.minimumDate = today
    picker.datePickerMode = .date
    picker.backgroundColor = UIColor.darkGray
    picker.tintColor = UIColor.white
    let loc = Locale.init(identifier: "ko")
    picker.locale = loc
    return picker
  }()
  
  var timePicker: UIDatePicker = {
    let timePicker = UIDatePicker()
    timePicker.datePickerMode = .time
    let loc = Locale.init(identifier: "ko")
    timePicker.locale = loc
    return timePicker
  }()
  
  var dateFormatter: DateFormatter = {
    let loc = Locale.init(identifier: "ko")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = loc
    return dateFormatter
  }()
  
  var timeFormatter: DateFormatter = {
    let loc = Locale.init(identifier: "ko")
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "a HH:mm"
    timeFormatter.amSymbol = "morning"
    timeFormatter.pmSymbol = "afternoon"
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short
    timeFormatter.locale = loc
    return timeFormatter
  }()
  
  
  
  
  //MARK: - Action
  // 저장 버튼( 추가 구현되야 하는것)
  // 1. Realm에 TextField에 있는 값을 저장.
  // 2. 알람 TextField에 있는 값을 기준으로 알람 시간 설정.( 알람 설정.)
    
  @IBAction func saveButton(_ sender: UIButton) {
    
    
    guard let goalStr = goalDetailTextField.text,
      goalDetailTextField.text != "",
      let startStr = startTextField.text,
      startTextField.text != "",
      let endStr = endTextField.text,
      endTextField.text != "",
      let alarmStr = alarmTextField.text,
      alarmTextField.text != "" else {
        let alertAC = UIAlertController(title: "Confirm", message: "Please check the value to input", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yeah", style: .cancel, handler: nil)
        alertAC.addAction(action)
        self.present(alertAC, animated: true, completion: nil)
        
        // 빈 값이 들어가게 될때 예외처리.
        switch "" {
        case goalDetailTextField.text:
          goalDetailTextField.shake()
        case startTextField.text:
          startTextField.shake()
        case endTextField.text:
          endTextField.shake()
        case alarmTextField.text:
          alarmTextField.shake()
        default:
          break
        }
        print("TextField의 값이 제대로 안들어 감.")
        return
    }
    // 1. Realm(Habit object)에 TextField에 있는 값을 저장.
    // 시작일과 종료일을 통해 일수를 계산 해야함. -  했고
    // 총 약속 일수 -> 총 알람 횟수임. - 했고
    // 종료일이 입력되는 시점(didPushDoneButtonOnEnd()) 에 목표 기간이 30일이 넘으면 Realm에 저장한다.
    
    // 1-1. 시작일과 종료일을 통해 목표일수와 10일 미만에 대한 계산을 통해 String, Bool 값을 반환 받는다.
    let (goalDay, isUpperTenDay) = HabitManager.getScheduledDay(startDay: startStr, endDay: endStr)
    // 목표일수 정해짐. 이 값은 종료일 입력 후 변경되야 함. 시점 변경 필요.
    if !isUpperTenDay{
      // 알람값 오후일경우 + 12로 넘겨줘야됨.
      HabitManager.add(addedHabit: HabitManager.init(goalStr,
                                                     totalCount: Int(goalDay)!,
                                                     currentCount: 0,
                                                     planedPiriod: String("\(startStr)~\(endStr)"),
                                                     startDay: startStr,
                                                     endDay: endStr,
                                                     sucessPromiss: false,
                                                     alarmTime: Util.convertTo24Hour(beforeConvertTime: alarmStr),
                                                     iConNo: "\(iconVC?.selectCategoryNo ?? 0)_\((iconVC?.selectItemNo)!+1)")) { (result) in
                                                      switch result{
                                                      case .sucess(let value):
                                                        print(value)
                                                      case .error(let error):
                                                        print(error)
                                                      }
      }
      
    }
    
    
    // 2. 알람 TextField에 있는 값을 기준으로 알람 시간 설정.( 알람 설정.)
    let alarmStrList = Util.convertTo24Hour(beforeConvertTime: alarmStr).components(separatedBy: ":")
    // DateComponents 를 사용하여 알람을 설정
    var dateComponent = DateComponents()
    dateComponent.hour = Int(alarmStrList[0])
    dateComponent.minute = Int(alarmStrList[1])
    if #available(iOS 10.0, *) {
        Util.timedNotification(date: dateComponent, identifierForAlarm: goalStr ) { (result) in
            switch result{
            case true:
                print("매일 \(goalStr)에 대한 알람이\(Util.convertTo24Hour(beforeConvertTime: alarmStr))에 울립니다.")
            case false:
                print("===UserNotification Add fail===")
            }
            
        }
    } else {
        // Fallback on earlier versions
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  //MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // 키보드 tap 제스쳐 처리.
    self.hideKeyboardWhenTappedAround()
    // 뷰가 불리면서 데이트 피커에 타깃 - 액션 부여
    createDatePicker()
    // 가장 자리 스와이프 했을때도 디스 미스 되도록.. HIG에 그렇게 좋지는..해보고 싶었따.
    dismissView()
    
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.startTextField.borderBottom(height: 0.5, color: .black)
    self.endTextField.borderBottom(height: 0.5, color: .black)
    self.alarmTextField.borderBottom(height: 0.5, color: .black)
  }
}


extension PromissDetailViewController{
  
    enum ToolbarType{
        case start
        case end
        case alarm
    }
    
  //PromissDetailViewController Dismiss를 위한 제스처
  func dismissView() {
    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
    edgePan.edges = .left
    view.addGestureRecognizer(edgePan)
  }
  //dissmiss Action 부분
  @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    if recognizer.state == .recognized {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func createDatePicker() {
    
    // TextField input toolbar/picker
    // Toolbar에 맞는 picker를 text Field에 set
    // -> tf별 objc 함수를 만드는것 보다 낳은 방법...?
    startTextField.inputAccessoryView = makeToolbar(toolType: PromissDetailViewController.ToolbarType.start)
    startTextField.inputView = picker
    endTextField.inputAccessoryView = makeToolbar(toolType: PromissDetailViewController.ToolbarType.end)
    endTextField.inputView = picker
    alarmTextField.inputAccessoryView = makeToolbar(toolType: PromissDetailViewController.ToolbarType.alarm)
    alarmTextField.inputView = timePicker
  }
  
  // enum type을 기준으로 toolbar 아이템을 생성하여 반환.
  func makeToolbar(toolType: ToolbarType) -> UIToolbar{
    // Toolbar 생성.
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    // toolbar 아이템 추가.
    var done: UIBarButtonItem
    switch toolType {
    case .start:
      done = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(didPushDoneButtonOnStart))
    case .end:
      done = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(didPushDoneButtonOnEnd))
    case .alarm:
      done = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(didPushDoneButtonOnAlarm))
    }
    
    let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(didPushCancelButton))
    toolbar.setItems([done, cancel], animated: false)
    
    return toolbar
  }
  
  // bar button cacel 눌렀을때.
  @objc func didPushCancelButton(_ sender: UIBarButtonItem){
    self.view.endEditing(true)
  }
  
  //MARK:- done button action
  
  // 시작일 에 대한 엑션
  @objc func didPushDoneButtonOnStart() {
    let dateString = dateFormatter.string(from: picker.date)
    startTextField.text = dateString    
    self.view.endEditing(true)
  }
  
  // 종료일 에 대한 엑션
  @objc func didPushDoneButtonOnEnd(){
    
    let dateString = dateFormatter.string(from: picker.date)
    // 시작일에 값이 들어 가있는지 체크
    // 값이 없을 경우 시작일 텍스트 필드로 포커스를 옮긴다.
    if let startStr = startTextField.text{
      if startStr == ""{
        self.startTextField.shake()
        self.startTextField.becomeFirstResponder()
        Util.toNotifyUserAlert(title: "Input error",
                               message: "Start date must be entered", parentController: self)
        return
      }else{
        endTextField.text = dateString
        if let endStr = endTextField.text{
          //약속 저장 일수에 대한 입력이 들어가야하는 시점,
          let (goalDay, isUpper30Day) = HabitManager.getScheduledDay(startDay: startStr, endDay: endStr)
          // 시작일도 입력되고, 종료일도 입력된 시점.
          print(goalDay, isUpper30Day)
          if !isUpper30Day{
            scheduleDayDetail.text = goalDay
          }else{
            self.startTextField.shake()
            self.startTextField.becomeFirstResponder()
            Util.toNotifyUserAlert(title: "Error setting date range", message: "Please set the date range from 1 day to less than 30 days.",
                                   parentController: self)
          }
        }
      }
    }
    self.view.endEditing(true)
    
    
  }
  
  // 알람 에 대한 엑션
  @objc func didPushDoneButtonOnAlarm(){
    let timeString = timeFormatter.string(from: timePicker.date)
    alarmTextField.text = timeString
    self.view.endEditing(true)
  }
  
  
  //MARK:- Remain Job
    //container View를 사용할때 prepare로 뷰를 넘긴 셈이 되고, 오버라이드를 통해 부모 뷰컨(?)에서 관리를 할수 있도록!
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? IconCollectionViewController{
      iconVC = vc
    }
  }
}

extension PromissDetailViewController: UITextFieldDelegate {// 텍필에 수정 진행될때 글자수 제한 
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = textField.text ?? ""
    let replacedText = (text as NSString).replacingCharacters(in: range, with: string)
    let _ = [NSAttributedStringKey.font: textField.font!]
    guard replacedText.count < 35 else { return false }
    return true
  }
}
