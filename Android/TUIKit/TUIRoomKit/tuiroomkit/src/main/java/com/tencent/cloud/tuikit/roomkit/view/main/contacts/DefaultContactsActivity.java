package com.tencent.cloud.tuikit.roomkit.view.main.contacts;


import static com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant.CustomSelector.CONFERENCE_PARTICIPANTS;
import static com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant.CustomSelector.SELECTED_PARTICIPANTS;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.impl.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.view.main.contacts.view.ContactsView;
import com.tencent.cloud.tuikit.roomkit.view.schedule.selectscheduleparticipant.ConferenceParticipants;


import java.util.ArrayList;
import java.util.List;

public class DefaultContactsActivity extends AppCompatActivity {

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle bundle = this.getIntent().getExtras();
        ConferenceParticipants participants = (ConferenceParticipants) bundle.getSerializable(CONFERENCE_PARTICIPANTS);
        if (participants == null) {
            return;
        }
        ContactsView contacts = new ContactsView(this);
        contacts.setContacts(ConferenceSessionImpl.sharedInstance().mParticipants, participants.selectedList, participants.unSelectableList);
        contacts.setConfirmSelectedCallback(new ContactsView.ConfirmSelectCallback() {
            @Override
            public void confirm(List<ConferenceDefine.User> selectedList) {
                Intent intent = new Intent();
                intent.putExtra(SELECTED_PARTICIPANTS, new ArrayList<>(selectedList));
                setResult(3, intent);
                finish();
            }
        });
        setContentView(contacts);
    }

}
