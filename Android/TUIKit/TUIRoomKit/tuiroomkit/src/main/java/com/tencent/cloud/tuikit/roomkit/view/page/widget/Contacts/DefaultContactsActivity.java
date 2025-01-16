package com.tencent.cloud.tuikit.roomkit.view.page.widget.Contacts;

import static com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant.CustomSelector.CONFERENCE_PARTICIPANTS;
import static com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant.CustomSelector.SELECTED_PARTICIPANTS;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Contacts.view.ContactsView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant.ConferenceParticipants;

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
