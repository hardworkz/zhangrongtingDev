//
//  UserXieYIViewController.m
//  Heard the news
//
//  Created by Pop Web on 15/10/15.
//  Copyright (c) 2015年 泡果网络. All rights reserved.
//

#import "UserXieYIViewController.h"

#import "CommonCode.h"

@interface UserXieYIViewController ()
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation UserXieYIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"用户协议";
    [self enableAutoBack];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSString *htmlString = @"在此特别提醒您（用户）在注册成为听闻用户之前，请认真阅读本《用户协议》（以下简称&ldquo;协议&rdquo;），确保您充分理解本协议中各条款。请您审慎阅读并选择接受或不接受本协议。除非您接受本协议所有条款，否则您无权注册、登录或使用本协议所涉服务。您的注册、登录、使用等行为将视为对本协议的接受，并同意接受本协议各项条款的约束。本协议约定听闻与用户之间关于&ldquo;听闻&rdquo;软件服务（以下简称&ldquo;服务&rdquo;）的权利义务。&ldquo;用户&rdquo;是指注册、登录、使用本服务的个人。本协议可由听闻随时更新，更新后的协议条款一旦公布即代替原来的协议条款，恕不再另行通知，用户可在本APP中查阅最新版协议条款。在修改协议条款后，如果用户不接受修改后的条款，请立即停止使用听闻提供的服务，用户继续使用听闻提供的服务将被视为接受修改后的协议。<br /> <br />一、账号注册<br />1、用户在使用本服务前需要注册一个&ldquo;听闻&rdquo;账号。&ldquo;听闻&rdquo;账号应当使用手机号码绑定注册，请用户使用尚未与&ldquo;听闻&rdquo;账号绑定的手机号码，以及未被听闻根据本协议封禁的手机号码注册&ldquo;听闻&rdquo;账号。听闻可以根据用户需求或产品需要对账号注册和绑定的方式进行变更，而无须事先通知用户。<br />2、鉴于&ldquo;听闻&rdquo;账号的绑定注册方式，您同意听闻在注册时将允许您的手机号码及手机设备识别码等信息用于注册。<br />3、在用户注册及使用本服务时，听闻需要搜集能识别用户身份的个人信息以便听闻可以在必要时联系用户，或为用户提供更好的使用体验。听闻搜集的信息包括但不限于用户的姓名、地址；听闻同意对这些信息的使用将受限于第三条用户个人隐私信息保护的约束。<br /> <br /> 二、用户个人隐私信息保护<br />1、如果听闻发现或收到他人举报或投诉用户违反本协议约定的，听闻有权不经通知随时对相关内容，包括但不限于用户资料、发贴记录进行审查、删除，并视情节轻重对违规账号处 以包括但不限于警告、账号封禁 、设备封禁 、功能封禁 的处罚，且通知用户处理结果。<br />2、因违反用户协议被封禁的用户，可以自行与听闻联系。其中，被实施功能封禁的用户会在封禁期届满后自动恢复被封禁功能。被封禁用户可提交申诉，听闻将对申诉进行审查，并自行合理判断决定是否变更处罚措施。<br />3、用户理解并同意，听闻有权依合理判断对违反有关法律法规或本协议规定的行为进行处罚，对违法违规的任何用户采取适当的法律行动，并依据法律法规保存有关信息向有关部门报告等，用户应承担由此而产生的一切法律责任。<br />4、用户理解并同意，因用户违反本协议约定，导致或产生的任何第三方主张的任何索赔、要求或损失，包括合理的律师费，用户应当赔偿听闻与合作公司、关联公司，并使之免受损害。<br /><br />三、用户发布内容规范<br />1、本条所述内容是指用户使用听闻的过程中所制作、上载、复制、发布、传播的任何内容，包括但不限于账号头像、名称、用户说明等注册信息及认证资料，或文字、语音、图片、视频、图文等发送、回复或自动回复消息和相关链接页面，以及其他使用账号或本服务所产生的内容。<br />2、用户不得利用&ldquo;听闻&rdquo;账号或本服务制作、上载、复制、发布、传播如下法律、法规和政策禁止的内容：<br />(1) 反对宪法所确定的基本原则的；<br />(2) 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；<br />(3) 损害国家荣誉和利益的；<br />(4) 煽动民族仇恨、民族歧视，破坏民族团结的；<br />(5) 破坏国家宗教政策，宣扬邪教和封建迷信的；<br />(6) 散布谣言，扰乱社会秩序，破坏社会稳定的；<br />(7) 散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；<br /> (8) 侮辱或者诽谤他人，侵害他人合法权益的；<br />(9) 含有法律、行政法规禁止的其他内容的信息。<br /> 3、用户不得利用&ldquo;听闻&rdquo;账号或本服务制作、上载、复制、发布、传播如下干扰&ldquo;听闻&rdquo;正常运营，以及侵犯其他用户或第三方合法权益的内容：<br />(1) 含有任何性或性暗示的；<br />(2) 含有辱骂、恐吓、威胁内容的；<br />(3) 含有骚扰、垃圾广告、恶意信息、诱骗信息的；<br />(4) 涉及他人隐私、个人信息或资料的；<br /> (5) 侵害他人名誉权、肖像权、知识产权、商业秘密等合法权利的；<br />(6) 含有其他干扰本服务正常运营和侵犯其他用户或第三方合法权益内容的信息。<br /><br /> 四、使用规则<br />1、用户在本服务中或通过本服务所传送、发布的任何内容并不反映或代表，也不得被视为反映或代表听闻的观点、立场或政策，听闻对此不承担任何责任。<br />2、用户不得利用&ldquo;听闻&rdquo;账号或本服务进行如下行为：<br />(1) 提交、发布虚假信息，或盗用他人头像或资料，冒充、利用他人名义的；<br />(2) 强制、诱导其他用户关注、点击链接页面或分享信息的；<br />(3) 虚构事实、隐瞒真相以误导、欺骗他人的；<br />(4) 利用技术手段批量建立虚假账号的；<br />(5) 利用&ldquo;听闻&rdquo;账号或本服务从事任何违法犯罪活动的；<br />(6) 制作、发布与以上行为相关的方法、工具，或对此类方法、工具进行运营或传播，无论这些行为是否为商业目的；<br />(7) 其他违反法律法规规定、侵犯其他用户合法权益、干扰&ldquo;听闻&rdquo;正常运营或听闻未明示授权的行为。<br /><br />3、用户须对利用&ldquo;听闻&rdquo;账号或本服务传送信息的真实性、合法性、无害性、准确性、有效性等全权负责，与用户所传播的信息相关的任何法律责任由用户自行承担，与听闻无关。 如因此给听闻或第三方造成损害的，用户应当依法予以赔偿。<br /><br />4、听闻提供的服务中可能包括广告，用户同意在使用过程中显示听闻和第三方供应商、合作伙伴提供的广告。除法律法规明确规定外，用户应自行对依该广告信息进行的交易负责， 对用户因依该广告信息进行的交易或前述广告商提供的内容而遭受的损失或损害，听闻不承担任何责任。<br /> <br />五、其他<br />1、听闻郑重提醒用户注意本协议中免除听闻责任和限制用户权利的条款，请用户仔细阅读，自主考虑风险。未成年人应在法定监护人的陪同下阅读本协议。<br />2、本协议的效力、解释及纠纷的解决，适用于中华人民共和国法律。若用户和听闻之间发生任何纠纷或争议，首先应友好协商解决，协商不成的，用户同意将纠纷或争议提交听闻住所地有管辖权的人民法院管辖。<br />3、本协议的任何条款无论因何种原因无效或不具可执行性，其余条款仍有效，对双方具有约束力。<ol> <li>4、本协议最终解释权归厦门泡果网络有限公司所有。</li> </ol>";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, IPHONE_W, IPHONE_H - 64)];
    [self.view addSubview:_webView];
    [self.webView loadHTMLString:htmlString baseURL:nil];

    UIButton *bs = [UIButton buttonWithType:UIButtonTypeCustom];
    [bs setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    bs.bounds = CGRectMake(0, 0, 9, 15);
    bs.center = CGPointMake(0, 22);
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [buttonView addSubview:bs];
    UITapGestureRecognizer *tapButton = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [buttonView addGestureRecognizer:tapButton];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = back;}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
