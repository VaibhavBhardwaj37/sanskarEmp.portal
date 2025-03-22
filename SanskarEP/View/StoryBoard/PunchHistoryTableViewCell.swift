import UIKit

class PunchHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var inTimeLabel: UILabel!
    @IBOutlet weak var outTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Ensure labels are center aligned and occupy equal width
        dateLabel.textAlignment = .center
        inTimeLabel.textAlignment = .center
        outTimeLabel.textAlignment = .center
        locationLabel.textAlignment = .center
    }
}
