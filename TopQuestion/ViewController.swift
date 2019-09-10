//
//  ViewController.swift
//  TopQuestion
//
//  Created by Matteo Manferdini on 10/09/2019.
//  Copyright © 2019 Matteo Manferdini. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var ownerNameLabel: UILabel!
	@IBOutlet weak var ownerAvatarImageView: UIImageView!
	@IBOutlet weak var ownerReputationLabel: UILabel!
	@IBOutlet weak var askedLabel: UILabel!
	@IBOutlet weak var tagsLabel: UILabel!
	
	private var loading = true
	private var request: AnyObject?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fetchQuestion()
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return loading ? 0.0 : UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

private extension ViewController {
	func configureUI(with question: Question) {
		scoreLabel.text = question.score.thousandsFormatting
		titleLabel.text = question.title
		set(tags: question.tags)
		ownerNameLabel.text = question.owner?.name
		ownerReputationLabel.text = question.owner?.reputation?.thousandsFormatting ?? nil
		loading = false
		tableView.reloadData()
	}
	
	func set(tags: [String]) {
		guard !tags.isEmpty else {
			tagsLabel.text = nil
			return
		}
		tagsLabel.text = tags[0] + tags.dropFirst().reduce("") { $0 + ", " + $1 }
	}
	
	func fetchQuestion() {
		let questionRequest = APIRequest(resource: QuestionsResource())
		request = questionRequest
		questionRequest.load { [weak self] (questions: [Question]?) in
			guard let questions = questions,
				let topQuestion = questions.first else {
					return
			}
			self?.configureUI(with: topQuestion)
			if let owner = topQuestion.owner {
				self?.fetchAvatar(for: owner)
			}
		}
	}
	
	func fetchAvatar(for user: User) {
		ownerAvatarImageView.image = nil
		guard let avatarURL = user.profileImageURL else {
			return
		}
		let avatarRequest = ImageRequest(url: avatarURL)
		self.request = avatarRequest
		avatarRequest.load(withCompletion: { [weak self] (avatar: UIImage?) in
			guard let avatar = avatar else {
				return
			}
			self?.ownerAvatarImageView.image = avatar
		})
	}
}

extension Int {
	var thousandsFormatting: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter.string(from: NSNumber(value: self))!
	}
}

extension Date {
	var timeAgo: String {
		let calendar = Calendar.current
		let units: Set<Calendar.Component> = [.month, .year]
		let components = calendar.dateComponents(units, from: self, to: Date())
		let year = components.year!
		let month = components.month!
		return "\(year) "
			+ (year > 1 ? "years" : "year")
			+ ", \(month) "
			+ (month > 1 ? "months" : "month")
			+ " ago"
	}
}
