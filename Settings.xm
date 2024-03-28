#import "Settings.h"

%subclass TWAdBlockSettingsViewController : TWBaseTableViewController
%property(nonatomic, assign) BOOL adblock;
%property(nonatomic, assign) BOOL proxy;
%property(nonatomic, assign) BOOL customProxy;
- (instancetype)initWithTableViewStyle:(NSInteger)tableViewStyle themeManager:(id)themeManager {
  if ((self = %orig)) {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    self.adblock = [userDefaults boolForKey:@"TWAdBlockEnabled"];
    self.proxy = [userDefaults boolForKey:@"TWAdBlockProxyEnabled"];
    self.customProxy = [userDefaults boolForKey:@"TWAdBlockCustomProxyEnabled"];
  }
  return self;
}
- (void)viewDidLoad {
  %orig;
  self.title = @"TwitchAdBlock";
  [self.view
      addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view
                                                                   action:@selector(endEditing:)]];
}
%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.adblock ? 2 : 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return 1;
    case 1:
      return self.proxy ? self.customProxy ? 3 : 2 : 1;
    default:
      return 0;
  }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  switch (indexPath.section) {
    case 0:
      cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
            initWithStyle:UITableViewCellStyleDefault
          reuseIdentifier:@"AdBlockSwitchCell"];
      [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
               configureWithTitle:@"Ad Block"
                         subtitle:nil
                        isEnabled:YES
                             isOn:[NSUserDefaults.standardUserDefaults
                                      boolForKey:@"TWAdBlockEnabled"]
          accessibilityIdentifier:@"AdBlockSwitchCell"];
      [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
      return cell;
    case 1:
      switch (indexPath.row) {
        case 0:
          cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"AdBlockProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
                   configureWithTitle:@"Ad Block Proxy"
                             subtitle:nil
                            isEnabled:YES
                                 isOn:[NSUserDefaults.standardUserDefaults
                                          boolForKey:@"TWAdBlockProxyEnabled"]
              accessibilityIdentifier:@"AdBlockProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
          return cell;
        case 1:
          cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"AdBlockCustomProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
                   configureWithTitle:@"Custom Proxy"
                             subtitle:nil
                            isEnabled:YES
                                 isOn:[NSUserDefaults.standardUserDefaults
                                          boolForKey:@"TWAdBlockCustomProxyEnabled"]
              accessibilityIdentifier:@"AdBlockCustomProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
          return cell;
        case 2:
          cell = [[objc_getClass("TWAdBlockSettingsTextFieldTableViewCell") alloc]
                initWithStyle:tableView.style
              reuseIdentifier:@"TWAdBlockProxy"];
          ((TWAdBlockSettingsTextFieldTableViewCell *)cell).textField.delegate = self;
          return cell;
      }
    default:
      return nil;
  }
}
%new
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return @"Choose whether you want to block ads or not.";
    case 1:
      return @"Proxy specific requests through a proxy server based in an ad-free country";
    default:
      return nil;
  }
}
%new
- (void)settingsCellSwitchToggled:(UISwitch *)sender {
  NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
  if ([sender.accessibilityIdentifier isEqualToString:@"AdBlockSwitchCell"]) {
    [userDefaults setBool:sender.isOn forKey:@"TWAdBlockEnabled"];
    self.adblock = sender.isOn;

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
    if (sender.isOn)
      [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
  } else if ([sender.accessibilityIdentifier isEqualToString:@"AdBlockProxySwitchCell"]) {
    [userDefaults setBool:sender.isOn forKey:@"TWAdBlockProxyEnabled"];
    self.proxy = sender.isOn;

    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:1]];
    if (self.customProxy) [indexPaths addObject:[NSIndexPath indexPathForRow:2 inSection:1]];
    if (sender.isOn)
      [self.tableView insertRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
  } else if ([sender.accessibilityIdentifier isEqualToString:@"AdBlockCustomProxySwitchCell"]) {
    [userDefaults setBool:sender.isOn forKey:@"TWAdBlockCustomProxyEnabled"];
    self.customProxy = sender.isOn;

    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:2 inSection:1] ];
    if (sender.isOn)
      [self.tableView insertRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
  }

  [userDefaults synchronize];
}
%new
- (void)textFieldDidEndEditing:(UITextField *)textField {
  [NSUserDefaults.standardUserDefaults setValue:textField.text forKey:@"TWAdBlockProxy"];
}
%end

%hook _TtC6Twitch25AppSettingsViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
    return [self.navigationController
        pushViewController:
            [[objc_getClass("TWAdBlockSettingsViewController") alloc]
                initWithTableViewStyle:2
                          themeManager:[objc_getClass("_TtC12TwitchCoreUI21TWDefaultThemeManager")
                                           defaultThemeManager]]
                  animated:YES];
  %orig;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return %orig + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    _TtC6Twitch22SettingsDisclosureCell *cell =
        [[objc_getClass("_TtC6Twitch22SettingsDisclosureCell") alloc]
              initWithStyle:UITableViewCellStyleSubtitle
            reuseIdentifier:@"Twitch.SettingsDisclosureCell"];
    cell.textLabel.text = @"TwitchAdBlock";
    return cell;
  }
  return %orig;
}
%end

%subclass TWAdBlockSettingsTextField : _TtC12TwitchCoreUI17StandardTextField
%new
- (id<UITextFieldDelegate>)delegate {
  return MSHookIvar<id<UITextFieldDelegate>>(self, "delegate");
}
%new
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  MSHookIvar<id<UITextFieldDelegate>>(self, "delegate") = delegate;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (!self.delegate || ![self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    return YES;
  return [self.delegate textFieldShouldBeginEditing:textField];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    [self textFieldDidBeginEditing:textField];
  MSHookIvar<BOOL>(self, "isEditing") = YES;
  self.backgroundColor = self.lastConfiguredTheme.backgroundBodyColor;
  self.layer.borderColor = self.lastConfiguredTheme.backgroundAccentColor.CGColor;
  self.layer.borderWidth = 2;
}
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (!self.delegate ||
      ![self.delegate respondsToSelector:@selector(textField:
                                             shouldChangeCharactersInRange:replacementString:)])
    return YES;
  return [self.delegate textField:textField
      shouldChangeCharactersInRange:range
                  replacementString:string];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if (!self.delegate || ![self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
    return YES;
  return [self.delegate textFieldShouldEndEditing:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    [self.delegate textFieldDidEndEditing:textField];
  MSHookIvar<BOOL>(self, "isEditing") = NO;
  self.backgroundColor = self.lastConfiguredTheme.backgroundInputColor;
  self.layer.borderWidth = 0;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (!self.delegate || ![self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
    return [textField resignFirstResponder];
  return [self.delegate textFieldShouldReturn:textField];
}
- (void)textFieldEditingChanged {
}
- (instancetype)initWithFrame:(CGRect)frame
                 themeManager:(_TtC12TwitchCoreUI21TWDefaultThemeManager *)themeManager {
  MSHookIvar<int>(self, "maximumLength") = INT_MAX;
  Class originalClass = object_setClass(self, UIView.class);
  if ((self = [self initWithFrame:frame])) {
    object_setClass(self, originalClass);
    self.themeManager = themeManager;
    self.applyShadowPathForElevation = YES;
    MSHookIvar<UITextField *>(self, "textField") =
        [[objc_getClass("_TtC12TwitchCoreUI13BaseTextField") alloc] init];
    UITextField *textField = MSHookIvar<UITextField *>(self, "textField");
    textField.borderStyle = UITextBorderStyleNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.returnKeyType = UIReturnKeyGo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.font = UIFont.twitchBody;
    textField.enablesReturnKeyAutomatically = YES;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    [textField addTarget:self
                  action:@selector(textFieldEditingChanged)
        forControlEvents:UIControlEventEditingChanged];
    [self addSubview:textField];
    CGFloat inputPadding = textField.intrinsicContentSize.width * 2;
    MSHookIvar<CGFloat>(self, "inputPadding") = inputPadding;
    NSArray<NSLayoutConstraint *> *textFieldConstraints = @[
      [self.leftAnchor constraintEqualToAnchor:textField.leftAnchor constant:-inputPadding],
      [self.rightAnchor constraintEqualToAnchor:textField.rightAnchor constant:inputPadding],
      [self.topAnchor constraintEqualToAnchor:textField.topAnchor],
      [self.bottomAnchor constraintEqualToAnchor:textField.bottomAnchor],
    ];
    [NSLayoutConstraint deactivateConstraints:MSHookIvar<NSArray<NSLayoutConstraint *> *>(
                                                  self, "_textFieldConstraints")];
    MSHookIvar<NSArray<NSLayoutConstraint *> *>(self, "_textFieldConstraints") =
        textFieldConstraints;
    [NSLayoutConstraint activateConstraints:textFieldConstraints];
  }
  return self;
}
- (void)dealloc {
  self.themeManager = nil;
  object_setClass(self, UIView.class);
  %orig;
}
%end

%subclass TWAdBlockSettingsTextFieldTableViewCell : TWBaseTableViewCell
%property(nonatomic, strong) TWAdBlockSettingsTextField *textField;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = %orig)) {
    self.textField = [[objc_getClass("TWAdBlockSettingsTextField") alloc]
        initWithFrame:self.frame
         themeManager:[objc_getClass("_TtC12TwitchCoreUI21TWDefaultThemeManager")
                          defaultThemeManager]];
    UITextField *textField = MSHookIvar<UITextField *>(self.textField, "textField");
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = PROXY_URL;
    textField.text = [NSUserDefaults.standardUserDefaults objectForKey:@"TWAdBlockProxy"];
    [self addSubview:self.textField];
  }
  return self;
}
- (void)layoutSubviews {
  %orig;
  self.textField.frame = self.bounds;
  self.textField.layer.cornerRadius = self.layer.cornerRadius;
}
%end

%ctor {
  NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
  if (![userDefaults objectForKey:@"TWAdBlockEnabled"])
    [userDefaults setBool:YES forKey:@"TWAdBlockEnabled"];
  if (![userDefaults objectForKey:@"TWAdBlockProxy"])
    [userDefaults setObject:PROXY_URL forKey:@"TWAdBlockProxy"];
  if (![userDefaults objectForKey:@"TWAdBlockProxyEnabled"])
    [userDefaults setBool:NO forKey:@"TWAdBlockProxyEnabled"];
  if (![userDefaults objectForKey:@"TWAdBlockCustomProxyEnabled"])
    [userDefaults setBool:NO forKey:@"TWAdBlockCustomProxyEnabled"];
}
