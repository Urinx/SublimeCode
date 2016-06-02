//
//  DonateViewController.swift
//  Sublime
//
//  Created by Eular on 5/6/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class DonateViewController: UITableViewController {

    let secTitle = [
        "Never doubt a little star can make a difference",
        "Because of you guys, I'm not alone anymore",
        "Money is devil, but devil push me to make this better",
        "2016.5 夏日小记"
    ]
    let cellText = [
        ["└─ Star Project:\(Config.Starred)"],
        ["└─ Follow Author:\(Config.FollowedAuthor)"],
        ["├─ Weixin Donate:\(Config.WeixinDonated)",
         "└─ AliPay Donate:\(Config.AlipayDonated)"],
        [
        "从2012年那个秋季踏入这个校园开始，没想到，四年就这样过去了，山河仍在，心境已改。说快不快，也不是那么的让人缓慢，倒有点像暴雨前夕般让人闷热难耐。",
        "大学四年，尽管都是从相同的起点走到相同的终点，可是在这样一个不满足柯西公式的世界里，路径不同，风景不同，结果总会让人相视无言。",
        "img:donate1",
        "此时我处于图书馆六楼一个坐在靠窗座位上的场景下，早上的图书馆人来的较少，之前复习的学生也随着刚过去的考试周而退潮，周围只有零星几个看书的少年。这个时候再回过头来看看自己大学这段时期，讲真，也没啥可回忆的。那个你曾经憧憬的大学生活，等你真正体验过，才明白原来不过如此。大学里让你映像最深刻的一件事是什么是一个很难回答的问题，至少，我给不出答案。",
        "有时候我不得不承认，自己确实是一个失败的人。每天浑浑噩噩，虚度光阴，三点一线的穿梭在校园，就像一部黑白默片，悄无声息的放映着，直到最后，才发现什么都没做，才发现自己是多么的一无是处。就像太宰治所说，生而为人，我很抱歉。",
        "img:donate2",
        "当我第一次注意到《咒怨》里的佐佐木希，我就发现我喜欢上她了，她在《天使之恋》里的表现也让人激动。我还记得有一个场景里，她那45度角仰望青空，若有所思的样子让人沉迷。不过让人遗憾的是，我的佐佐木希并没有在大学四年里出现在我的身边，尽管我也曾多么希望有那么一位能一起共享这段时光。好吧，诸事难遂人意，强争无益。",
        "img:donate3",
        "为什么做这个，也许是自己闲的蛋疼，也许是给自己这四年最后的一个交代。记得是那天晚上，我又一次的失眠了，与外界的安逸不同，内心的躁动让我辗转反侧。掏出手机，微信上各种小红点以及庞大的信息流让人无所适从，夜深人静的时候，有时你会发现，莫名的，自己突然想看看代码了。",
        "在手机上阅读源码，就是这么简单的一件事，在App store上搜索了半天，代码阅读的应用没几个，也没有一个令人满意的：Codeanywhere的代码是存在云端要联网；CodeMate支持多种代码，但功能单一；Pythonista最强大，能够在手机上本地运行python脚本无所不能，具有多种主题，不过价格较贵，且主要是针对python代码。在现实面前，这是我唯一能做到的不妥协和不将就。所以，那就自己做了，就这样。",
        "img:donate4",
        "安迪·安德鲁斯说过，人的一生中至少有两次冲动，一次奋不顾身的爱情，一次说走就走的旅行。世界那么大，说实话，还真没怎么看过，我想去看看。",
        "img:donate5",
        "（完） ——  2016.5.31  K.K M"
        ]
    ]
    let headerHeight: CGFloat = 300
    let headerImage = UIImageView()
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donate"
        view.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.TableCellSeparatorColor
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        headerImage.frame = CGRectMake(0, -headerHeight, view.width, headerHeight)
        headerImage.image = UIImage(named: "donate")
        headerImage.contentMode = .ScaleAspectFill
        tableView.addSubview(headerImage)
        tableView.sendSubviewToBack(headerImage)
        
        do {
            player = try AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("山外小楼夜听雨.m4a", withExtension: nil)!)
            player.numberOfLoops = -1
            player.play()
        } catch {}
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        headerImage.frame = CGRectMake(0, point.y, view.width, -point.y)
        
        if point.y > -headerHeight && point.y <= 0 {
            tableView.contentInset = UIEdgeInsets(top: abs(point.y), left: 0, bottom: 0, right: 0)
        } else if point.y > 0 {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel(frame: CGRectMake(0, 0, view.width, Constant.FilesTableSectionHight))
        title.backgroundColor = Constant.CapeCod
        title.text = "   "+secTitle[section]
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(12)
        title.textAlignment = .Natural
        let headerView = UIView()
        headerView.addSubview(title)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return secTitle.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellText[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.backgroundColor = Constant.TableCellColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.tintColor = UIColor.whiteColor()
        
        let text = cellText[indexPath.section][indexPath.row]
        if indexPath.section == secTitle.count - 1 {
            cell.selectedBackgroundView?.backgroundColor = Constant.TableCellColor
            cell.textLabel?.numberOfLines = 0

            if text.hasPrefix("img:") {
                let name = text.split(":")[1]
                let width = view.width - 17 * 2
                cell.imageView?.image = UIImage(named: name)?.rescaleImageByWidth(width)
            } else {
                cell.textLabel?.text = text
                cell.textLabel?.lineBreakMode = .ByCharWrapping
                cell.textLabel?.font = cell.textLabel?.font.fontWithSize(15)
            }
        } else {
            cell.textLabel?.text = text.split(":")[0]
            cell.accessoryType = text.split(":")[1] == "true" ? .Checkmark : .DisclosureIndicator
            cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            if !Config.Starred {
                if GitHubAPIManager.isLogin {
                    if Network.isConnectedToNetwork() {
                        let github = GitHubAPIManager()
                        github.star("Urinx", repo: "WeixinBot", success: {
                            let cell = tableView.cellForRowAtIndexPath(indexPath)
                            cell?.accessoryType = .Checkmark
                            Config.Starred = true
                        }, fail: {
                            self.view.window?.Toast(message: "The network is not well, please try again")
                        })
                    } else {
                        view.window?.Toast(message: "Error: No network")
                    }
                } else {
                    let alert = UIAlertController(title: "(*´ڡ`●)", message: "Ops! This function requires that Github account is logined.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
        case (1,0):
            if !Config.FollowedAuthor {
                if GitHubAPIManager.isLogin {
                    if Network.isConnectedToNetwork() {
                        let github = GitHubAPIManager()
                        github.follow("Urinx", success: {
                            let cell = tableView.cellForRowAtIndexPath(indexPath)
                            cell?.accessoryType = .Checkmark
                            Config.FollowedAuthor = true
                        }, fail: {
                                self.view.window?.Toast(message: "The network is not well, please try again")
                        })
                    } else {
                        view.window?.Toast(message: "Error: No network")
                    }
                } else {
                    let alert = UIAlertController(title: "(*´ڡ`●)", message: "Ops! This function requires that Github account is logined.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
        case (2,0):
            // https://wx.tenpay.com/f2f?t=AQAAAAKUGF%2BtHt037N4rgTLUV54%3D
            Config.WeixinDonated = true
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
            WXShareImage(UIImage(named: "donate_weixin")!)
        case (2,1):
            // #吱口令#gSstPA146v
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = "#吱口令#gSstPA146v"
            Config.AlipayDonated = true
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
            UIApplication.sharedApplication().openURL(NSURL(string: "alipay://")!)
        default:
            break
        }
    }

}
